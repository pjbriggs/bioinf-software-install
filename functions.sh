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
    echo $($1 --version 2>&1 | cut -d" " -f2 | cut -d. -f1-2)
}
function prepend_path() {
    # Prepend path to path-type variable
    # 1: path variable name e.g. PATH
    # 2: path to prepend e.g. /home/$USER/bin
    eval local path=\$$1
    if [ -z "$path" ] ; then
	eval $1=$2
    else
	eval $1=$2:$path
    fi
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
    local targz=$(basename $1)
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
    # 1: archive file
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
	*)
	    echo "Unrecognised compression type '$type'" >&2
	    exit 1
	    ;;
    esac
    echo -n Unpacking $1...
    tar -$tar_options $1
    if [ -d $(package_dir $1) ] ; then
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
    # 1: archive file
    # 2: installation directory
    # 3: Python interpreter
    echo -n Entering directory $(package_dir $1)...
    cd $(package_dir $1)
    echo done
    echo -n Checking python...
    if [ -f $3 ] && [ -x $3 ] ; then
	echo ok
    else
	echo FAILED
	echo $3 is not an executable file
	if [ -d $3 ] ; then
	    echo Did you mean $3/python?
	fi
	echo ERROR $3 is not an executable file >&2
	exit 1
    fi
    echo -n Detecting python version...
    local python_version=python$(python_version $3)
    echo $python_version
    local lib_dir=$2/lib/$python_version/site-packages
    echo -n Making $lib_dir...
    mkdir -p $lib_dir
    echo done
    echo -n Prepending $lib_dir to PYTHONPATH...
    prepend_path PYTHONPATH $lib_dir
    echo done
    echo -n Installing into $2...
    local install_cmd="$3 setup.py install --prefix=$2"
    $install_cmd > install.log 2>&1
    if [ "$?" -eq 0 ] ; then
	echo done
    else
	echo FAILED
	exit 1
    fi
}
##
#
