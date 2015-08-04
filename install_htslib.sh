#!/bin/bash
#
# Install htslib
# Works for 1.0
#
. $(dirname $0)/import_functions.sh
#
TARBZ2=$1
INSTALL_DIR=$2
if [ -z "$TARBZ2" ] || [ -z "$INSTALL_DIR" ] ; then
  echo Usage: $(basename $0) TARBZ2 INSTALL_DIR
  echo Installs htslib to INSTALL_DIR/htslib/VERSION
  exit 1
fi
HTSLIB_DIR=$(package_dir $TARBZ2)
HTSLIB_VER=$(package_version $TARBZ2)
INSTALL_DIR=$(full_path $INSTALL_DIR)/htslib/$HTSLIB_VER
echo Build htslib from $TARBZ2
echo Version $HTSLIB_VER
unpack_archive $TARBZ2
# Set up build log
LOG_FILE=$(pwd)/install.htslib.$HTSLIB_VER.log
clean_up_file $LOG_FILE
# Build htslib
echo Moving to $HTSLIB_DIR
cd $HTSLIB_DIR
echo done
do_make --log $LOG_FILE
# Install
create_directory $INSTALL_DIR
do_make --log $LOG_FILE prefix=$INSTALL_DIR install
# Finish up
cd ..
clean_up $TARBZ2
##
#
