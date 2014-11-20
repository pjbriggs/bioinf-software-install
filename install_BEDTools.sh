#!/bin/sh
#
# Install BEDTools
#
# Works with bedtools 2.17.0
#            bedtools 2.18.2
#            bedtools 2.19.1
#            bedtools 2.21.0
#            bedtools 2.22.0
#
. $(dirname $0)/import_functions.sh
#
TARGZ=$1
INSTALL_DIR=$2
if [ -z "$TARGZ" ] || [ -z "$INSTALL_DIR" ] ; then
  echo Usage: $(basename $0) TARGZ INSTALL_DIR
  echo Installs BEDTools to INSTALL_DIR/bedtools/VERSION
  exit 1
fi
# Unpack the archive
BEDTOOLS_DIR=$(package_dir $TARGZ)
BEDTOOLS_VER=$(package_version $TARGZ)
INSTALL_DIR=$(full_path $INSTALL_DIR)/bedtools/$BEDTOOLS_VER
echo Build bedtools from $TARGZ
echo Version $BEDTOOLS_VER
unpack_archive --no-package-dir-check $TARGZ
# Look for unpacked directory
echo Locating bedtools source directory
for d in $BEDTOOLS_DIR bedtools2-${BEDTOOLS_VER} bedtools2 ; do
  echo -n Checking for directory $d...
  if [ ! -d $d ] ; then
      echo not found
  else
      echo found
      bedtools_dir=$d
      break
  fi
done
if [ -z "$bedtools_dir" ] ; then
  echo ERROR no source code directory found >&2
  exit 1
fi
BEDTOOLS_DIR=$bedtools_dir
# Set up build log file
LOG_FILE=$(pwd)/install.bedtools.$BEDTOOLS_VER.log
clean_up_file $LOG_FILE
# Build
echo Moving to $BEDTOOLS_DIR
cd $BEDTOOLS_DIR
do_make --log $LOG_FILE
# Copy executables to installation location
echo Copying BEDTools executables
create_directory $INSTALL_DIR
copy_files bin/* $INSTALL_DIR
cd ..
clean_up_dir $BEDTOOLS_DIR
##
#
