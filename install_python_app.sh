#!/bin/sh
#
# Install Python application
#
. $(dirname $0)/import_functions.sh
#
PYTHON=$1
TARGZ=$2
INSTALL_DIR=$3
if [ -z "$PYTHON" ] || [ -z "$TARGZ" ] || [ -z "$INSTALL_DIR" ] ; then
  echo Usage: $(basename $0) PYTHON TARGZ INSTALL_DIR
  echo Installs application into INSTALL_DIR/NAME/VERSION
  exit 1
fi
APP_NAME=$(package_name $TARGZ)
APP_NAME_LOWER=$(to_lower $APP_NAME)
APP_VERSION=$(package_version $TARGZ)
PYTHON=$(full_path $PYTHON)
TARGZ=$(full_path $TARGZ)
INSTALL_DIR=$(full_path $INSTALL_DIR)/$APP_NAME_LOWER/$APP_VERSION
echo "## Install $APP_NAME  ##"
echo Using Python from $(dirname $PYTHON)
echo Installing under $INSTALL_DIR
echo Archive $TARGZ
echo Version $APP_VERSION
unpack_archive $TARGZ
install_python_package $PYTHON $TARGZ $INSTALL_DIR
clean_up $TARGZ
##
#