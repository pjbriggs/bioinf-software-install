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
function package_dir() {
    # Get directory for package in targz archive
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
