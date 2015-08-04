#!/bin/bash
#
# Fetch and install Annovar binaries
#
. $(dirname $0)/import_functions.sh
#
TARGZ=$1
ANNOVAR_VERSION=$2
INSTALL_DIR=$3
if [ -z "TARGZ" ] || [ -z "$ANNOVAR_VERSION" ] || [ -z "$INSTALL_DIR" ] ; then
  echo Usage: $(basename $0) TARGZ VERSION INSTALL_DIR
  echo 
  echo Installs ANNOVAR binaries from TARGZ to INSTALL_DIR/annovar/VERSION
  exit 1
fi
echo Install ANNOVAR as version $ANNOVAR_VERSION
# Install
unpack_archive --no-package-dir-check $TARGZ
ANNOVAR_DIR=annovar
INSTALL_DIR=$(full_path $INSTALL_DIR)/annovar/$ANNOVAR_VERSION
echo -n Creating $INSTALL_DIR...
mkdir -p $INSTALL_DIR
echo done
copy_contents $ANNOVAR_DIR $INSTALL_DIR
clean_up_dir $ANNOVAR_DIR
##
#
