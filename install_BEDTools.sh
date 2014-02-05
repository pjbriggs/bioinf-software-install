#!/bin/sh
#
# Install BEDTools
#
. $(dirname $0)/functions.sh
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
if [ ! -d $BEDTOOLS_DIR ] ; then
  echo ERROR no directory $BEDTOOLS_DIR found >&2
  exit 1
fi
echo Moving to $BEDTOOLS_DIR
cd $BEDTOOLS_DIR
echo -n Running 'make'...
make >> build.log 2>&1
if [ $? -ne 0 ] ; then
    echo FAILED
    echo ERROR failed to build BEDTools, see $BEDTOOLS_DIR/build.log >&2
    exit 1
else
    echo done
fi
# Copy executables to installation location
echo -n Copying BEDTools executables to $INSTALL_DIR...
mkdir -p $INSTALL_DIR
cp bin/* $INSTALL_DIR
echo done
cd ..
clean_up $TARGZ
##
#
