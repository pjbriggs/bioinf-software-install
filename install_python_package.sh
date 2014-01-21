#!/bin/sh
#
# Install Python package
#
# Script for installing a Python package into an arbitray local using an
# arbitrary Python version, from an archive file on the local system
#
. $(dirname $0)/functions.sh
#
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