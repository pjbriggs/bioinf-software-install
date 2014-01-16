#!/bin/sh
#
# Install Python package
#
# Script for installing a Python package into an arbitray local using an
# arbitrary Python version, from an archive file on the local system
#
function full_path() {
    # Convert relative path to full path by prepending PWD
    if [ -z "$1" ] ; then
	echo $1
    fi
    local is_abs=$(echo $1 | grep "^/")
    if [ -z "$is_abs" ] ; then
	echo $(pwd)/${1#./}
    else
	echo $1
    fi
}
function to_lower() {
    # Convert string to lowercase
    echo $(echo $1 | tr [:upper:] [:lower:])
}
function python_version() {
    echo $($1 --version 2>&1 | cut -d" " -f2 | cut -d. -f1-2)
}
function prepend_path() {
    # 1: path variable name
    eval local path=\$$1
    if [ -z "$path" ] ; then
	eval $1=$2
    else
	eval $1=$2:$path
    fi
}
function package_dir() {
    # 1: tar.gz file
    local targz=$(basename $1)
    if [ ! -z "$(echo $1 | grep tar.gz)" ] ; then
	local tgz=tar.gz
    else
	local tgz=tgz
    fi
    echo ${targz%.$tgz}
}
function package_name() {
    # 1: tar.gz file
    echo $(package_dir $1) | cut -d"-" -f1
}
function package_version() {
    # 1: tar.gz file
    echo $(package_dir $1) | cut -d"-" -f2
}
function unpack_archive() {
    # 1: tar.gz file
    echo -n Unpacking $1...
    tar -zxf $1
    if [ -d $(package_dir $1) ] ; then
	echo done
    else
	echo FAILED
	echo ERROR no directory $(package_dir $1) found >&2
	exit 1
    fi
}
function install_package() {
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
# Main script
PYTHON=$1
TARGZ=$2
INSTALL_DIR=$3
if [ -z "$PYTHON" ] || [ -z "$TARGZ" ] || [ -z "$INSTALL_DIR" ] ; then
  echo Usage: $(basename $0) PYTHON TARGZ INSTALL_DIR
  exit 1
fi
PYTHON=$(full_path $PYTHON)
INSTALL_DIR=$(full_path $INSTALL_DIR)
echo "## Install $(package_name $TARGZ) ##"
echo Archive $TARGZ
echo Version $(package_version $TARGZ)
echo Using Python from $(dirname $PYTHON)
echo Installing under $INSTALL_DIR
unpack_archive $TARGZ
install_package $TARGZ $INSTALL_DIR $PYTHON
##
#