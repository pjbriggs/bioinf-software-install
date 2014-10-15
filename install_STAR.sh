#!/bin/sh
#
# Install STAR mapper
# Works for 2.4.0d
#
. $(dirname $0)/import_functions.sh
#
TARGZ=$1
INSTALL_DIR=$2
if [ -z "$TARGZ" ] || [ -z "$INSTALL_DIR" ] ; then
  echo Usage: $(basename $0) TARGZ INSTALL_DIR
  echo Installs STAR mapper to INSTALL_DIR/STAR/VERSION
  exit 1
fi
#
STAR_DIR=$(package_dir $TARGZ)
STAR_VER=$(echo $STAR_DIR | cut -d"_" -f 2)
INSTALL_DIR=$(full_path $INSTALL_DIR)/STAR/$STAR_VER
echo Build STAR mapper from $TARGZ
echo Version $STAR_VER
unpack_archive $TARGZ
# Set up build log
LOG_FILE=$(pwd)/install.STAR.$STAR_VER.log
clean_up_file $LOG_FILE
echo Moving to $STAR_DIR
# Build
cd $STAR_DIR
do_make --log $LOG_FILE
# Install
create_directory $INSTALL_DIR
copy_file STAR $INSTALL_DIR
# Finish up
cd ..
clean_up $TARGZ
##
#
