#!/bin/sh
#
# Function library for build/install scripts
#
function full_path() {
    # Convert relative path to full path by prepending PWD
    if [ -z "$1" ] ; then
	echo $1
    fi
    local is_abs=$(echo $1 | grep "^/")
    if [ -z "$is_abs" ] ; then
	if [ "$1" == "." ] ; then
	    local path=$(pwd)
	else
	    local path=$(pwd)/${1#./}
	fi
    else
	local path=$1
    fi
    echo ${path%/}
}
function to_lower() {
    # Convert string to lowercase
    # 1: string to convert
    echo $(echo $1 | tr [:upper:] [:lower:])
}
function python_version() {
    # Fetch Python version (major.minor)
    # 1: python executable (incl path if necessary)
    echo $($1 --version 2>&1 | cut -d" " -f2 | cut -d. -f1-2)
}
function python_lib_dir() {
    # Return full lib directory for Python package installation
    # e.g. BASE_DIR/lib64/python2.7/site-packages
    # 1: python executable
    # 2: top-level library dir e.g. /home/pjb/site-python
    local version=$(python_version $1)
    local python_lib=$($1 -c "import distutils.sysconfig; print (distutils.sysconfig.get_python_lib(1,0));")
    if [ -z "$(echo $python_lib | grep /lib64/)" ] ; then
	local lib=lib
    else
	local lib=lib64
    fi
    echo $2/$lib/python$version/site-packages
}
function python_package_installed() {
    # Crude way of checking if a Python package is installed
    # Returns package version if found, empty string otherwise
    # 1: python executable
    # 2: package name
    local yolk=$(which yolk 2>/dev/null)
    if [ ! -z "$yolk" ] ; then
	local package_version=$($yolk -l -f version $2 2>&1| grep Version: | cut -d":" -f2 | tr -d " ")
	if [ -z "$package_version" ] ; then
	    local import_package="No module named $2"
	fi
    else
	local package_version=$($1 -c "import $2; print $2.__version__" 2>&1)
	local import_package=$(echo $package_version | grep "ImportError: No module named $2")
    fi
    if [ -z "$import_package" ] ; then
	echo $package_version
    else
	echo ''
    fi
}
function create_virtualenv() {
    # Create a Python virtualenv in pwd
    # 1: name of virtualenv
    echo -n Making virtualenv \'$1\'...
    if [ -d "$1" ] ; then
	echo FAILED
	echo Directory for virtualenv already exists >&2
	exit 1
    fi
    virtualenv $1 2>&1 >/dev/null
    if [ $? -ne 0 ] ; then
	echo ERROR
	echo virtualenv returned non-zero status
	exit 1
    fi
    echo done
}
function activate_virtualenv() {
    # Active an existing virtualenv
    # 1: name/path of virtualenv
    echo -n Activating virtualenv \'$1\'...
    local activate_script=$(full_path $1)/bin/activate
    if [ ! -f $activate_script ] ; then
	echo FAILED
	echo No activation script $activate_script >&2
	exit 1
    fi
    . $activate_script
    echo ok
}
function R_version() {
    # Fetch R version (major.minor)
    echo $($1 --version 2>&1 | grep "^R version" | cut -d" " -f3 | cut -d. -f1-2)
}
function R_package_installed() {
    # Crude way of checking if an R package is installed
    # Returns package version if found, empty string otherwise
    # 1: R executable
    # 2: package name
    local package_info=$(echo 'installed.packages()[,c("Package","Version")]' | $1 --vanilla | grep ^$2)
    if [ ! -z "$package_info" ] ; then
	echo $package_info | cut -d'"' -f4
    else
	echo ''
    fi
}
function perl_version() {
    # Fetch perl version (major.minor)
    echo $($1 -v 2>&1 | grep "^This is perl" | cut -d"(" -f2 | cut -d")" -f1 | tr -d "v" | cut -d. -f1-2)
}
function install_cpanminus() {
    # Install cpnaminus into Perl distribution
    # 1: Perl executable (full path)
    echo -n Install cpanminus...
    # Use method from StackOverflow: http://stackoverflow.com/a/3462743/579925
    wget -q -O - http://cpanmin.us | $1 - --self-upgrade > install.cpanm.log 2>&1
    if [ $? -ne 0 ] ; then
	echo FAILED
	echo See log file install.cpanm.log for more information
	echo Unable to install cpanm into Perl distribution >&2
	exit 1
    else
	echo ok
	clean_up_file install.cpanm.log
    fi
}
function install_perl_package() {
    # Install Perl package using cpanm
    # 1: perl executable (full path)
    # 2: package to install
    # 3: installation directory
    echo -n Installing $PACKAGE using cpanm...
    local cpanm=$(dirname $1)/cpanm
    if [ ! -x "$cpanm" ] ; then
	echo FAILED
	echo No executable $cpanm >&2
	exit 1
    fi
    $cpanm -l $3 $2 > install.$2.perl$(perl_version $1).log 2>&1
    if [ $? -ne 0 ] ; then
	echo FAILED
	echo See log file install.$2.perl$(perl_version $1).log for more information
	echo Unable to install $2 into $3 >&2
	exit 1
    else
	echo done
    fi
}
function wget_url() {
    # Fetch a URL using wget
    # 1: url to retrieve
    echo -n Fetching $(basename $1) from $1...
    wget --no-check-certificate -q $1
    if [ ! -e "$(basename $1)" ] ; then
	echo FAILED
	return 1
    fi
    echo done
    return 0
}
function package_dir() {
    # Get directory for package in targz/zip archive
    # 1: archive file
    local archive=$(basename "$1")
    if [ ! -z "$(echo $1 | grep tar.gz)" ] ; then
	local ext=tar.gz
    elif [ ! -z "$(echo $1 | grep tgz)" ] ; then
	local ext=tgz
    elif [ ! -z "$(echo $1 | grep tar.bz2)" ] ; then
	local ext=tar.bz2
    elif [ ! -z "$(echo $1 | grep zip)" ] ; then
	local ext=zip
    fi
    echo ${archive%.$ext}
}
function package_name() {
    # Get name for package in targz archive
    # 1: tar.gz file
    echo $(package_dir $1) | cut -d"-" -f1
}
function package_version() {
    # Get version for package in targz archive
    # 1: tar.gz file
    echo $(package_dir $1) | cut -d"-" -f2
}
function unpack_archive() {
    # Unpack targz archive to cwd
    # --no-package-dir-check: don't check if package dir exists
    # 1: archive file
    local package_dir_check=yes
    if [ "$1" == "--no-package-dir-check" ] ; then
	package_dir_check=
	shift
    fi
    if [ ! -f "$1" ] ; then
	echo ERROR no archive file $1 >&2
	exit 1
    fi
    echo -n Determining archive type...
    local type=${1##*.}
    echo $type
    local tar_options=xf
    case "$type" in
	gz|tgz)
	    tar_options=z${tar_options}
	    ;;
	bz2)
	    tar_options=j${tar_options}
	    ;;
	zip)
	    ;;
	*)
	    echo "Unrecognised compression type '$type'" >&2
	    exit 1
	    ;;
    esac
    echo -n Unpacking $1...
    if [ "$type" == "zip" ] ; then
	unzip -qq -o $1
    else
	tar -$tar_options $1
    fi
    if [ -z "$package_dir_check" ] || [ -d $(package_dir $1) ] ; then
	echo done
    else
	echo FAILED
	echo ERROR no directory $(package_dir $1) found >&2
	exit 1
    fi
}
function create_directory() {
    # Create a directory with mkdir -p
    # 1: target directory to create
    echo -n Creating directory $1...
    if [ -d "$1" ] ; then
	echo already exists
    fi
    mkdir -p $1
    if [ $? -ne 0 ] ; then
	FAILED
	exit 1
    else
	echo done
    fi
}
function set_env_var() {
    # Set the value of an environment variable 
    # 1: variable name
    # 2: new value
    local var=$1
    shift
    local val=$@
    echo -n Setting $var...
    eval $var='$val'
    export $var
    echo $val
}
function check_directory() {
    # Check if directory exists
    # 1: target directory to check
    echo -n Checking for directory $1...
    if [ ! -d "$1" ] ; then
	echo FAILED
	echo ERROR $1 not found >&2
	exit 1
    else
	echo ok
    fi
}
function check_program() {
    # Check if program is available
    # 1: name/path of program to look for
    echo -n Checking for program $1...
    local path=$(which $1 2>&1)
    if [ -f "$path" ] ; then
	echo ok \($path\)
    else
	echo FAILED
	echo ERROR $1 not found >&2
	exit 1
    fi
}
function do_configure() {
    # Run 'configure' using supplied arguments
    # Optionally: first pair of arguments can be "--log FILE"
    # then stdout and stderr are appended to FILE
    # Remaining args are passed to configure
    local log="&1"
    if [ "$1" == "--log" ] ; then
	shift
	log=$1
	shift
    fi
    local configure_cmd="./configure $@"
    echo Configure command: $configure_cmd >>$log
    echo -n Running configure...
    if [ ! -f "./configure" ] ; then
	echo FAILED
	echo No configure script in $(pwd) >&2
	exit 1
    fi
    $configure_cmd >>$log 2>&1
    if [ $? -ne 0 ] ; then
	echo FAILED
	echo ERROR configure returned non-zero exit code >&2
	exit 1
    else
	echo ok
    fi
}
function do_make() {
    # Run 'make' using supplied arguments
    # Optionally: first pair of arguments can be "--log FILE"
    # then stdout and stderr are appended to FILE
    # Remaining args are passed to make
    local log="&1"
    if [ "$1" == "--log" ] ; then
	shift
	log=$1
	shift
    fi
    echo Make command: make $@ >>$log
    if [ $# -eq 0 ] ; then
	echo -n Running make...
    else
	echo -n Running make $@...
    fi
    make $@ >>$log 2>&1
    if [ $? -ne 0 ] ; then
	echo FAILED
	echo ERROR make returned non-zero exit code >&2
	exit 1
    else
	echo ok
    fi
}
function copy_contents() {
    # Copy contents of directory to another directory
    # 1: source directory
    # 2: target directory
    echo -n Copying contents of $1 to $2...
    if [ ! -d "$1" ] ; then
	echo FAILED
	echo No directory $1 >&2
    elif [ ! -d "$2" ] ; then
	echo FAILED
	echo No directory $2 >&2
    else
	cp -r $1/* $2
	echo done
    fi
}
function copy_files() {
    # Copy one or more files to another location
    # 1(,2,...,n-1): file(s) to copy
    # Last argument: target directory
    #
    # Optionally: specify --exe as first argument
    # to only copy executable files
    local only_exe=
    if [ "$1" == "--exe" ] ; then
	only_exe=yes
	shift
    fi
    for last; do true; done
    local dir=$last
    while [ $# -gt 1 ] ; do
	if [ -z "$only_exe" ] || [ -x $1 ] ; then
	    if [ -f $1 ] ; then
		copy_file $1 $dir
	    fi
	fi
	shift
    done
}
function copy_file() {
    # Copy file to another location
    # 1: file to copy
    # 2: target directory
    echo -n Copying $(basename $1) from $(dirname $1) to $2...
    if [ ! -f "$1" ] ; then
	echo FAILED
	echo No file $1 >&2
    elif [ ! -d "$2" ] ; then
	echo FAILED
	echo No directory $2 >&2
    else
	cp $1 $2
	if [ -x $1 ] ; then
	    chmod +rx $2/$(basename $1)
	else
	    chmod +r $2/$(basename $1)
	fi
	echo done
    fi
}
function clean_up() {
    # Remove directory created when unpacking archive
    # 1: archive file
    echo -n Cleaning up $(package_dir $1)...
    if [ -d "$(package_dir $1)" ] ; then
	rm -rf $(package_dir $1)
	echo done
    else
	echo FAILED
        echo No directory $(package_dir $1) to remove
    fi
}
function clean_up_file() {
    # Remove file
    # 1: file
    echo -n Cleaning up $1...
    if [ -f "$1" ] ; then
	rm -f $1
	echo done
    else
	echo not found
    fi
}
function clean_up_dir() {
    # Remove directory and contents
    # 1: dir
    echo -n Cleaning up $1...
    if [ -d "$1" ] ; then
	rm -rf $1
	echo done
    else
	echo not found
    fi
}
function pip_install() {
    # Install Python package using pip
    # 1: python bin directory (full path)
    # 2: package specifier
    local pip_install_cmd="$1/pip install"
    local package=$(basename $2)
    local pip_install_log="pip_install.${package%%=}.log"
    if [ ! -z "$($pip_install_cmd -h | grep '\--no-use-wheel')" ] ; then
	pip_install_cmd="$pip_install_cmd --no-use-wheel"
    fi
    pip_install_cmd="$pip_install_cmd $2"
    echo -n "Installing $package using pip ($pip_install_cmd)..."
    $pip_install_cmd >$pip_install_log  2>&1
    status=$?
    if [ "$status" -eq 0 ] ; then
	echo done
    else
	echo FAILED
	echo "!!!! Installation of '$package' failed: see log $pip_install_log !!!!"
    fi
    return $status
}
function install_python_package() {
    # Install a Python package from an archive
    # 1: Python interpreter
    # 2: archive file
    # 3: installation directory
    echo -n Entering directory $(package_dir $2)...
    cd $(package_dir $2)
    echo done
    echo -n Checking python...
    if [ -f $1 ] && [ -x $1 ] ; then
	echo ok
    else
	echo FAILED
	echo $1 is not an executable file
	if [ -d $1 ] ; then
	    echo Did you mean $1/python?
	fi
	echo ERROR $1 is not an executable file >&2
	exit 1
    fi
    echo -n Determining library path...
    local lib_dir=$(python_lib_dir $1 $3)
    echo $lib_dir
    echo -n Making $lib_dir...
    mkdir -p $lib_dir
    echo done
    echo -n Prepending $lib_dir to PYTHONPATH...
    prepend_path PYTHONPATH $lib_dir
    echo done
    echo -n Installing into $3...
    local install_cmd="$1 setup.py install --prefix=$3"
    $install_cmd > install.log 2>&1
    if [ "$?" -eq 0 ] ; then
	local package=$(package_name $2)
	echo done: version $(python_package_installed $1 $package)
    else
	echo FAILED
	exit 1
    fi
    echo -n Setting read permissions on EGG-INFO files...
    find $lib_dir -type d -name "EGG-INFO" -exec chmod -R +rX {} \;
    echo done
    cd ..
}
##
#
