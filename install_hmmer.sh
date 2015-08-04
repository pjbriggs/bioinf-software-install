#!/bin/bash
#
# Install hmmer
# Works for 3.1b1
#
. $(dirname $0)/import_functions.sh
#
TARGZ=$1
INSTALL_DIR=$2
if [ -z "$TARGZ" ] || [ -z "$INSTALL_DIR" ] ; then
  echo Usage: $(basename $0) TARGZ INSTALL_DIR
  echo Installs hmmer to INSTALL_DIR/hmmer/VERSION
  exit 1
fi
HMMER_DIR=$(package_dir $TARGZ)
HMMER_VER=$(package_version $TARGZ)
INSTALL_DIR=$(full_path $INSTALL_DIR)/hmmer/$HMMER_VER
echo Build samtools from $TARGZ
echo Version $HMMER_VER
unpack_archive $TARGZ
# Set up build log
LOG_FILE=$(pwd)/install.hmmer.$HMMER_VER.log
clean_up_file $LOG_FILE
echo Moving to $HMMER_DIR
cd $HMMER_DIR
# Build
do_configure --log $LOG_FILE
do_make --log $LOG_FILE
# Install
create_directory $INSTALL_DIR
do_make --log $LOG_FILE prefix=$INSTALL_DIR install
# Finish up
cd ..
clean_up $TARGZ
##
#
