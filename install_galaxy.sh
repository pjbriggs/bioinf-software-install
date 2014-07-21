#!/bin/sh -f
#
# Install and configure local Galaxy
#
. $(dirname $0)/import_functions.sh
#
# Functions
function hg_clone() {
    # Run hg clone on a repository
    # 1: repo URL
    local log=
    if [ "$1" == "--log" ] ; then
	shift
	log=$1
	shift
    else
	log=hg_clone.$(basename $1).log
    fi
    echo -n "Cloning hg repo $1..."
    hg clone $1 >> $log
    if [ $? -ne 0 ] || [ ! -d $(basename $1) ] ; then
	echo FAILED
	echo Error cloning repo, see $log >&2
	exit 1
    fi
    echo "ok"
}
function configure_galaxy() {
    # Update the value of a parameter in the
    # universe_wsgi.ini file
    # 1: parameter
    # 2: new value
    local universe_wsgi=universe_wsgi.ini
    if [ -z "$2" ] ; then
	return
    fi
    if [ ! -f "$universe_wsgi" ] ; then
	echo ERROR
	echo No file \'$universe_wsgi\' >&2
	exit 1
    fi
    echo -n Setting \'$1\' to \'$2\' in $universe_wsgi...
    # Escape special characters in value (commas,slashes)
    local s=$(echo $2 | cut -d, -f1- --output-delimiter='\,')
    s=$(echo $s | cut -d/ -f1- --output-delimiter='\/')
    sed -i 's,#'"$1"' = .*,'"$1"' = '"$s"',' $universe_wsgi
    if [ $? -ne 0 ] ; then
	echo FAILED
	exit 1
    else
	echo done
    fi
}
function run_command() {
    # Wrapper to run an arbitrary command
    # run_command [ --log LOG ] DESCRIPTION CMD ARGS...
    # Optionally first two arguments can be '--log LOG'
    # to specify a file to send stdout/stderr to (defaults
    # to /dev/null)
    # 1: description text
    # 2...: command line to execute
    local log=
    if [ "$1" == "--log" ] ; then
	shift
	log=$1
	shift
    fi
    if [ -z "$log" ] ; then
	log=/dev/null
    fi
    echo -n $1
    shift
    echo -n " ($@)..."
    $@ >>$log 2>&1
    if [ $? -ne 0 ] ; then
	echo FAILED
    else
	echo done
    fi
}
# Main script
GALAXY_DIR=
port=
admin_users=
release_tag=
# Command line
while [ $# -ge 1 ] ; do
    if [ "$1" == "--port" ] ; then
        # User specified port number
	shift
	if [ ! -z "$1" ] ; then
	    port=$1
	fi
    elif [ "$1" == "--admin_users" ] ; then
	shift
	if [ ! -z "$1" ] ; then
	    admin_users=$1
	fi
    elif [ "$1" == "--release" ] ; then
	shift
	if [ ! -z "$1" ] ; then
	    release_tag=$1
	fi
    elif [ "$1" == "-h" ] || [ "$1" == "--help" ] ; then
	usage
	exit 0
    else
	if [ $# -eq 1 ] ; then
	    GALAXY_DIR=$(full_path $1)
	else
	    echo "Unrecognised argument: $1"
	fi
    fi
    # Next argument
    shift
done
if [ -z "$GALAXY_DIR" ] ; then
  echo ERROR no directory specified >&2
  exit 1
elif [ -e $GALAXY_DIR ] ; then
  echo ERROR $GALAXY_DIR: directory already exists >&2
  exit 1
fi
echo "###################################################"
echo "### Install and configure local Galaxy instance ###"
echo "###################################################"
# Check prerequisites
check_program virtualenv
check_program hg
check_program pwgen
check_program R
check_program samtools
# Set up install log
LOG_FILE=$(pwd)/install.galaxy.$(basename $GALAXY_DIR).log
clean_up_file $LOG_FILE
# Start
create_directory $GALAXY_DIR
cd $GALAXY_DIR
# Create and activate a Python virtualenv for this instance
create_virtualenv galaxy_venv
activate_virtualenv galaxy_venv
# Install NumPy
pip_install galaxy_venv/bin numpy
# Install patched Rpy
pip_install galaxy_venv/bin \
    https://dl.dropbox.com/s/r0lknbav2j8tmkw/rpy-1.0.3-patched.tar.gz?dl=1
# Fetch Galaxy code
hg_clone https://bitbucket.org/galaxy/galaxy-dist
cd galaxy-dist
run_command --log $LOG_FILE "Switching to Galaxy stable branch" hg update stable
if [ ! -z "$release_tag" ] ; then
    run_command --log $LOG_FILE "Pulling in all updates" hg pull
    run_command --log $LOG_FILE "Switching to release tag $release_tag" hg update $release_tag
fi
# Create custom universe_wsgi.ini file
run_command "Creating universe_wsgi.ini file" cp universe_wsgi.ini.sample universe_wsgi.ini
echo Configuring settings in universe_wsgi.ini
configure_galaxy id_secret $(pwgen 8 1)
configure_galaxy port $port
configure_galaxy admin_users $admin_users
configure_galaxy brand "$(basename $GALAXY_DIR)"
configure_galaxy tool_config_file tool_conf.xml,shed_tool_conf.xml,local_tool_conf.xml
configure_galaxy allow_library_path_paste True
# Set the master API key for bootstrapping
##configure_galaxy master_api_key $(pwgen 16 1)
# Initialise: fetch eggs, copy sample file, create database etc
run_command --log $LOG_FILE "Fetching python eggs" python scripts/fetch_eggs.py
run_command --log $LOG_FILE "Copying sample files" scripts/copy_sample_files.sh
run_command --log $LOG_FILE "Creating the database" python scripts/create_db.py
run_command --log $LOG_FILE "Migrating tools" sh manage_tools.sh upgrade
cd ..
# Create directories for local and shed tools
echo Creating supporting directories
create_directory local_tools
create_directory shed_tools
create_directory managed_packages
# Make conf file for local tools
echo -n Creating empty local_tool_conf.xml file...
cat > galaxy-dist/local_tool_conf.xml <<EOF
<?xml version="1.0"?>
<toolbox tool_path="../local_tools">
<label id="local_tools" text="Local Tools" />
  <!-- Example of section and tool definitions -->
  <section id="example_tools" name="Local Tools">
  	<!--Add tool references here-->
  </section>
</toolbox>
EOF
echo done
# Create wrapper script to run galaxy
echo -n Making generic wrapper script \'start_galaxy.sh\'...
cat > start_galaxy.sh <<EOF
#!/bin/sh
# Automatically generated script to run galaxy
# in $(basename $GALAXY_DIR)
GALAXY_DIR=\$(dirname \$0)
if [ -z \$(echo \$GALAXY_DIR | grep "^/") ] ; then
  GALAXY_DIR=\$(pwd)/\$GALAXY_DIR
fi
echo -n Starting Galaxy from \$GALAXY_DIR
if [ ! -z "$@" ] ; then
  echo using options:
  echo \$@
else
  echo
fi
# Activate virtualenv
. \$GALAXY_DIR/galaxy_venv/bin/activate
# Start Galaxy with --reload option
cd \$GALAXY_DIR/galaxy-dist
sh run.sh --reload \$@ 2>&1 | tee \$GALAXY_DIR/galaxy.log
EOF
chmod +x start_galaxy.sh
echo done
# Finished
deactivate
echo "Finished installing Galaxy in $GALAXY_DIR"
# 
##
#
