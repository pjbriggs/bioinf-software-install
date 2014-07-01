#!/bin/sh
#
# Install RSEM
#
# Works for version 1.2.12
#
. $(dirname $0)/import_functions.sh
#
TARGZ=$1
INSTALL_DIR=$2
if [ -z "$TARGZ" ] || [ -z "$INSTALL_DIR" ] ; then
  echo Usage: $(basename $0) TARGZ INSTALL_DIR
  echo Installs RSEM to INSTALL_DIR/rsem/VERSION
  echo Nb EBSeq will not be installed, use install_bioc_package.sh
  exit 1
fi
RSEM_DIR=$(package_dir $TARGZ)
RSEM_VER=$(package_version $TARGZ)
INSTALL_DIR=$(full_path $INSTALL_DIR)/rsem/$RSEM_VER
echo Build RSEM from $TARGZ
echo Version $RSEM_VER
unpack_archive $TARGZ
if [ ! -d $RSEM_DIR ] ; then
  echo ERROR no directory $RSEM_DIR found >&2
  exit 1
fi
LOG_FILE=$(pwd)/install.rsem.$RSEM_VER.log
clean_up_file $LOG_FILE
# Build
echo Moving to $RSEM_DIR
cd $RSEM_DIR
do_make --log $LOG_FILE
create_directory $INSTALL_DIR
echo Installing executables
copy_files --exe * $INSTALL_DIR
cd ..
clean_up $TARGZ
##
#
