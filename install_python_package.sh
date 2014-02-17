#!/bin/sh
#
# Install Python package
#
# Script for installing a Python package into an arbitrary location
# using an arbitrary Python version, from an archive file on the
# local system
#
. $(dirname $0)/functions.sh
#
# Main script
if [ "$1" == "--force" ] ; then
    force_install=yes
    shift
fi
PYTHON=$1
TARGZ=$2
INSTALL_DIR=$3
if [ -z "$PYTHON" ] || [ -z "$TARGZ" ] || [ -z "$INSTALL_DIR" ] ; then
  echo Usage: $(basename $0) \[--force\] PYTHON TARGZ INSTALL_DIR
  exit 1
fi
PYTHON=$(full_path $PYTHON)
PYTHON_VER=$(python_version $PYTHON)
PACKAGE_NAME=$(package_name $TARGZ)
INSTALL_DIR=$(full_path $INSTALL_DIR)/$PYTHON_VER
echo "## Install $PACKAGE_NAME ##"
echo Archive $TARGZ
echo Version $(package_version $TARGZ)
echo Using Python from $(dirname $PYTHON)
echo Installing under $INSTALL_DIR
echo -n Checking if $PACKAGE_NAME is already installed...
prepend_path PYTHONPATH $(python_lib_dir $PYTHON $INSTALL_DIR)
if [ ! -z "$(python_package_installed $PYTHON $PACKAGE_NAME)" ] ; then
    echo found version $(python_package_installed $PYTHON $PACKAGE_NAME)
    if [ -z "$force_install" ] ; then
	echo $PACKAGE_NAME already installed, use --force to override
	exit
    fi
    echo Reinstalling $PACKAGE_NAME
else
    echo no
fi
unpack_archive $TARGZ
install_python_package $PYTHON $TARGZ $INSTALL_DIR
clean_up $TARGZ
##
#
