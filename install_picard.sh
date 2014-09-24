#!/bin/sh
#
# Fetch and install Picard binaries
#
# For versions <= 1.119 download from sourceforge
# For versions >= 1.120 download from github
#
. $(dirname $0)/import_functions.sh
#
PICARD_VERSION=$1
INSTALL_DIR=$2
if [ -z "$PICARD_VERSION" ] || [ -z "$INSTALL_DIR" ] ; then
  echo Usage: $(basename $0) PICARD_VERSION\|ZIP_FILE INSTALL_DIR
  echo 
  echo Installs picard-tools binaries to INSTALL_DIR/picard-tools/VERSION
  echo 
  echo If first argument is an existing zip archive then install directly
  echo from that, otherwise download zip archive for the given version
  exit 1
fi
# Command line
if [ -f $PICARD_VERSION ] ; then
  ZIP_FILE=$PICARD_VERSION
  PICARD_VERSION=$(package_dir $ZIP_FILE | cut -d"-" -f3)
else
  do_download=yes
  ZIP_FILE=picard-tools-${PICARD_VERSION}.zip
fi
echo Install Picard tools version $PICARD_VERSION
# Acquire archive
if [ -z "$do_download" ] ; then
  echo Using existing zip archive $ZIP_FILE
else
  if [ -f $ZIP_FILE ] ; then
     echo ERROR $ZIP_FILE already exists >&2
     exit 1
  fi
  # Determine download location from version
  MAJOR_PICARD_VERSION=$(echo $PICARD_VERSION | cut -d"." -f1)
  MINOR_PICARD_VERSION=$(echo $PICARD_VERSION | cut -d"." -f2)
  if [ "$MAJOR_PICARD_VERSION" == 1 ] && [ "$MINOR_PICARD_VERSION" -le 119 ] ; then
    ZIP_URL=http://sourceforge.net/projects/picard/files/picard-tools
  else
    ZIP_URL=https://github.com/broadinstitute/picard/releases/download
  fi
  ZIP_URL=$ZIP_URL/${PICARD_VERSION}/$ZIP_FILE
  wget_url $ZIP_URL
fi
# Install
unpack_archive $ZIP_FILE
INSTALL_DIR=$(full_path $INSTALL_DIR)/picard-tools/$PICARD_VERSION
echo -n Creating $INSTALL_DIR...
mkdir -p $INSTALL_DIR
echo done
copy_contents $(package_dir $ZIP_FILE) $INSTALL_DIR
# Clean up
clean_up $ZIP_FILE
if [ -f snappy-java-1.0.3-rc3.jar ] ; then
  clean_up_file snappy-java-1.0.3-rc3.jar
fi
##
#

