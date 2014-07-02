#!/bin/sh
#
# Build R
#
. $(dirname $0)/import_functions.sh
#
TARGZ=$1
INSTALL_DIR=$2
if [ -z "$TARGZ" ] || [ -z "$INSTALL_DIR" ] ; then
  echo Usage: $(basename $0) TARGZ INSTALL_DIR
  echo Installs R to INSTALL_DIR/R/VERSION
  exit 1
fi
R_DIR=$(package_dir $TARGZ)
R_VER=$(package_version $TARGZ)
echo Build R from $TARGZ
echo Version $R_VER
INSTALL_DIR=$(full_path $INSTALL_DIR)/R/$R_VER
LOG_FILE=$(pwd)/install.R.$R_VER.log
clean_up_file $LOG_FILE
unpack_archive $TARGZ
echo Moving to $R_DIR
cd $R_DIR
do_configure --log $LOG_FILE --prefix=$INSTALL_DIR
do_make --log $LOG_FILE
create_directory $INSTALL_DIR
do_make --log $LOG_FILE install
cd ..
clean_up $TARGZ
##
#
