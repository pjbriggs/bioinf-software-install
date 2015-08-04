#!/bin/bash
#
# Install bcftools
# Works for 1.0
#
. $(dirname $0)/import_functions.sh
#
TARBZ2=$1
INSTALL_DIR=$2
if [ -z "$TARBZ2" ] || [ -z "$INSTALL_DIR" ] ; then
  echo Usage: $(basename $0) TARBZ2 INSTALL_DIR
  echo Installs bcftools 1.0+ to INSTALL_DIR/bcftools/VERSION
  exit 1
fi
BCFTOOLS_DIR=$(package_dir $TARBZ2)
BCFTOOLS_VER=$(package_version $TARBZ2)
INSTALL_DIR=$(full_path $INSTALL_DIR)/bcftools/$BCFTOOLS_VER
echo Build bcftools from $TARBZ2
echo Version $BCFTOOLS_VER
unpack_archive $TARBZ2
# Set up build log
LOG_FILE=$(pwd)/install.bcftools.$BCFTOOLS_VER.log
clean_up_file $LOG_FILE
# Build bcftools
echo Moving to $BCFTOOLS_DIR
cd $BCFTOOLS_DIR
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
