#!/bin/sh
#
# Install samtools
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
echo Moving to $RSEM_DIR
cd $RSEM_DIR
echo -n Building RSEM in $RSEM_DIR...
make >> build.log 2>&1
echo done
echo -n Creating $INSTALL_DIR...
mkdir -p $INSTALL_DIR
echo done
echo Installing executables
for f in $(ls) ; do
  if [ -f $f ] && [ -x $f ] ; then
    copy_file $f $INSTALL_DIR
  fi
done
cd ..
clean_up $TARGZ
##
#
