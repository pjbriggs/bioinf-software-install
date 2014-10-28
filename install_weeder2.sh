#!/bin/sh
#
# Install Weeder2
# Works for 2.0
#
. $(dirname $0)/import_functions.sh
#
TARGZ=$1
INSTALL_DIR=$2
if [ -z "$TARGZ" ] || [ -z "$INSTALL_DIR" ] ; then
  echo Usage: $(basename $0) TARGZ INSTALL_DIR
  echo Installs weeder2 to INSTALL_DIR/weeder/VERSION
  exit 1
fi
WEEDER_DIR=$(package_dir $TARGZ)
WEEDER_VER=$(echo $WEEDER_DIR | tr -d '[a-z]')
INSTALL_DIR=$(full_path $INSTALL_DIR)/weeder/$WEEDER_VER
echo Build weeder2 from $TARGZ
echo Version $WEEDER_VER
# Set up build log
LOG_FILE=$(pwd)/install.weeder.$WEEDER_VER.log
clean_up_file $LOG_FILE
# Unpack archive
create_directory $WEEDER_DIR
echo Moving to $WEEDER_DIR
cd $WEEDER_DIR
unpack_archive --no-package-dir-check $TARGZ
# Update FreqFiles location in source code to point to
# final installation location
echo -n Setting location of FreqFiles in source code...
sed -i 's,./FreqFiles,'"$INSTALL_DIR/FreqFiles"',g' weeder2.cpp
echo done
# Build
BUILD_CMD="g++ weeder2.cpp -o weeder2 -O3"
echo -n Running $BUILD_CMD...
$BUILD_CMD >> $LOG_FILE 2>&1
if [ -x weeder2 ] ; then
    echo ok
else
    echo FAILED
    echo ERROR failed to create weeder2 executable >&2
    exit 1
fi
# Install
create_directory $INSTALL_DIR
create_directory $INSTALL_DIR/FreqFiles
copy_file weeder2 $INSTALL_DIR
copy_file README.txt $INSTALL_DIR
copy_files FreqFiles/* $INSTALL_DIR/FreqFiles
# Finish up
cd ..
clean_up $TARGZ
##
#
