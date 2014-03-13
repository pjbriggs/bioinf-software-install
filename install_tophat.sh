#!/bin/sh
#
# Fetch and install tophat binaries
#
. $(dirname $0)/functions.sh
#
TOPHAT_VERSION=$1
INSTALL_DIR=$2
if [ -z "$TOPHAT_VERSION" ] || [ -z "$INSTALL_DIR" ] ; then
  echo Usage: $(basename $0) TOPHAT_VERSION_TARGZ INSTALL_DIR
  echo Downloads and installs tophat binaries to INSTALL_DIR/tophat/VERSION
  exit 1
fi
echo Install Tophat version $TOPHAT_VERSION
TGZ_FILE=tophat-${TOPHAT_VERSION}.Linux_x86_64.tar.gz
TGZ_URL=http://tophat.cbcb.umd.edu/downloads/$TGZ_FILE
if [ -f $TGZ_FILE ] ; then
  echo ERROR $TGZ_FILE already exists >&2
  exit 1
fi
wget_url $TGZ_URL
unpack_archive $TGZ_FILE
TOPHAT_DIR=$(package_dir $TGZ_FILE)
if [ ! -d $TOPHAT_DIR ] ; then
  echo ERROR no directory $TOPHAT_DIR >&2
fi
INSTALL_DIR=$(full_path $INSTALL_DIR)/tophat/$TOPHAT_VERSION
echo -n Creating $INSTALL_DIR...
mkdir -p $INSTALL_DIR
echo done
echo -n Copying contents of $TOPHAT_DIR to $INSTALL_DIR...
cp -r $TOPHAT_DIR/* $INSTALL_DIR
echo done
if [ -d "$TOPHAT_DIR" ] ; then
    echo -n Removing directory $TOPHAT_DIR...
    rm -rf $TOPHAT_DIR
    echo done
fi
echo "#%Module1.0"
echo "## tophat $TOPHAT_VERSION modulefile"
echo "prepend-path PATH            $INSTALL_DIR"
echo 
##
#


