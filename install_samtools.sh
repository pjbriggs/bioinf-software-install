#!/bin/sh
#
# Install samtools
#
. $(dirname $0)/functions.sh
#
TARGZ=$1
INSTALL_DIR=$2
if [ -z "$TARGZ" ] || [ -z "$INSTALL_DIR" ] ; then
  echo Usage: $(basename $0) TARGZ INSTALL_DIR
  echo Installs samtools and bcftools to INSTALL_DIR/samtools/VERSION
  exit 1
fi
SAMTOOLS_DIR=$(package_dir $TARGZ)
SAMTOOLS_VER=$(package_version $TARGZ)
INSTALL_DIR=$(full_path $INSTALL_DIR)/samtools/$SAMTOOLS_VER
echo Build samtools from $TARGZ
echo Version $SAMTOOLS_VER
unpack_archive $TARGZ
if [ ! -d $SAMTOOLS_DIR ] ; then
  echo ERROR no directory $SAMTOOLS_DIR found >&2
  exit 1
fi
echo -n Building in $SAMTOOLS_DIR...
cd $SAMTOOLS_DIR
make >> build.log 2>&1
echo done
echo -n Looking for bcftools subdirectory...
if [ ! -d bcftools ] ; then
  echo missing
  echo ERROR no bcftools subdirectory found >&2
  exit 1
fi
echo ok
echo -n Building in bcftools...
cd bcftools
make >> ../build.log 2>&1
echo done
cd ..
echo -n Copying samtools executable to $INSTALL_DIR...
mkdir -p $INSTALL_DIR
cp samtools $INSTALL_DIR
echo done
echo -n Copying bcftools executable to $INSTALL_DIR...
cp bcftools/bcftools $INSTALL_DIR
echo done
cd ..
clean_up $TARGZ
##
#
