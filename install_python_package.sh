#!/bin/sh
#
# Install Python package
#
# Script for installing a Python package into an arbitray local using an
# arbitrary Python version, from an archive file on the local system
#
. $(dirname $0)/functions.sh
#
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
install_python_package $TARGZ $INSTALL_DIR $PYTHON
clean_up $TARGZ
##
#
