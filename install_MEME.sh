#!/bin/sh
#
# Install MEME suite
#
# Known to work for MEME versions:
# - 4.8.1 (unpatched)
# - 4.9.1_2
# - 4.10.0_1
#
. $(dirname $0)/import_functions.sh
#
TARGZ=$1
INSTALL_DIR=$2
if [ -z "$TARGZ" ] || [ -z "$INSTALL_DIR" ] ; then
  echo Usage: $(basename $0) TARGZ INSTALL_DIR
  echo Installs MEME suite to INSTALL_DIR/meme/VERSION
  exit 1
fi
MEME_DIR=$(package_dir $TARGZ)
MEME_VER=$(echo $MEME_DIR | cut -d'_' -f2-)
MEME_PATCH=$(echo $MEME_DIR | cut -d'_' -f3)
if [ ! -z "$MEME_PATCH" ] ; then
  MEME_DIR=$(echo $MEME_DIR | cut -d'_' -f1-2)
fi
INSTALL_DIR=$(full_path $INSTALL_DIR)/meme/$MEME_VER
echo Build MEME suite from $TARGZ
echo -n Version $MEME_VER
if [ ! -z "$MEME_PATCH" ] ; then
  echo
else
  echo " (unpatched)"
fi
# Set up build log
LOG_FILE=$(pwd)/install.meme.$MEME_VER.log
clean_up_file $LOG_FILE
# Unpack source code
unpack_archive --no-package-dir-check $TARGZ
check_directory $MEME_DIR
# Do build and install
echo Moving to $MEME_DIR
cd $MEME_DIR
do_configure --log $LOG_FILE \
    --enable-build-libxslt \
    --enable-build-libxml2 \
    --disable-web \
    --prefix=$INSTALL_DIR
do_make --log $LOG_FILE
create_directory $INSTALL_DIR
do_make --log $LOG_FILE install
# Finish up
cd ..
clean_up_dir $MEME_DIR
##
#
