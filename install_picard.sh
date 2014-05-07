#!/bin/sh
#
# Fetch and install Picard binaries
#
. $(dirname $0)/functions.sh
#
PICARD_VERSION=$1
INSTALL_DIR=$2
if [ -z "$PICARD_VERSION" ] || [ -z "$INSTALL_DIR" ] ; then
  echo Usage: $(basename $0) PICARD_VERSION INSTALL_DIR
  echo Downloads and installs picard-tools binaries to INSTALL_DIR/picard-tools/VERSION
  exit 1
fi
echo Install Picard tools version $PICARD_VERSION
ZIP_FILE=picard-tools-${PICARD_VERSION}.zip
ZIP_URL=http://sourceforge.net/projects/picard/files/picard-tools/${PICARD_VERSION}/$ZIP_FILE
if [ -f $ZIP_FILE ] ; then
  echo ERROR $ZIP_FILE already exists >&2
  exit 1
fi
wget_url $ZIP_URL
unpack_archive $ZIP_FILE
INSTALL_DIR=$(full_path $INSTALL_DIR)/picard-tools/$PICARD_VERSION
echo -n Creating $INSTALL_DIR...
mkdir -p $INSTALL_DIR
echo done
copy_contents $(package_dir $ZIP_FILE) $INSTALL_DIR
clean_up $ZIP_FILE
clean_up_file snappy-java-1.0.3-rc3.jar
##
#

