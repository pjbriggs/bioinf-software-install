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
    # Fetch Python version
    # 1: python executable (incl path if necessary)
    echo $($1 --version 2>&1 | cut -d" " -f2 | cut -d. -f1-2)
}
function python_package_installed() {
    # Crude way of checking if a Python package is installed
    # 1: python executable
    # 2: package name
    local import_package=$($1 -c "import $2" 2>&1 | grep "ImportError: No module named $2")
    if [ -z "$import_package" ] ; then
	echo $2
    else
	echo ''
    fi
}
function R_version() {
    # Fetch R version
    echo $($1 --version 2>&1 | grep "^R version" | cut -d" " -f3 | cut -d. -f1-2)
}
function R_package_installed() {
    # Crude way of checking if an R package is installed
    # 1: R executable
    # 2: package name
    if [ ! -z "$(echo 'installed.packages()' | $1 --vanilla | grep ^$2)" ] ; then
	echo $2
    else
	echo ''
    fi
}
function prepend_path() {
    # Prepend path to path-type variable
    # 1: path variable name e.g. PATH
    # 2: path to prepend e.g. /home/$USER/bin
    remove_path $1 $2
    eval local path=\$$1
    if [ ! -z "$path" ] ; then
	new_path=$2:$path
    else
	new_path=$2
    fi
    eval $1=$new_path
    export $1
}
function remove_path() {
    # Remove path from path-type variable
    # 1: path variable name e.g. PATH
    # 2: path to remove
    eval local path=\$$1
    local new_path=
    if [ ! -z "$path" ] ; then
	while [ ! -z "$path" ] ; do
	    local el=$(echo $path | cut -d":" -f1)
	    path=$(echo $path | cut -s -d":" -f2-)
	    if [ ! -z "$el" ] && [ "$el" != "$2" ] ; then
		if [ -z "$new_path" ] ; then
		    new_path=$el
		else
		    new_path=$new_path:$el
		fi
	    fi
	done
    fi
    eval $1=$new_path
    export $1
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
    # Get directory for package in targz archive
    # 1: tar.gz file
    local targz=$(basename "$1")
    if [ ! -z "$(echo $1 | grep tar.gz)" ] ; then
	local tgz=tar.gz
    elif [ ! -z "$(echo $1 | grep tgz)" ] ; then
	local tgz=tgz
    elif [ ! -z "$(echo $1 | grep tar.bz2)" ] ; then
	local tgz=tar.bz2
    fi
    echo ${targz%.$tgz}
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
	echo ERROR no archive file '$1' >&2
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
function clean_up() {
    # Remove directory created when unpacking archive
    # 1: archive file
    echo -n Cleaning up...
    if [ -d "$(package_dir $1)" ] ; then
	rm -rf $(package_dir $1)
    fi
    echo done
}
function pip_install() {
    # Install Python package using pip
    # 1: python bin directory (full path)
    # 2: package specifier
    local pip_install_cmd="$1/pip install"
    if [ ! -z "$($pip_install_cmd -h | grep '\--no-use-wheel')" ] ; then
	pip_install_cmd="$pip_install_cmd --no-use-wheel"
    fi
    pip_install_cmd="$pip_install_cmd $2"
    echo -n "$pip_install_cmd"...
    $pip_install_cmd > pip_install.${2%%=}.log 2>&1
    status=$?
    if [ "$status" -eq 0 ] ; then
	echo done
    else
	echo FAILED
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
    echo -n Detecting python version...
    local python_version=python$(python_version $1)
    echo $python_version
    local lib_dir=$3/lib/$python_version/site-packages
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
	echo done
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
