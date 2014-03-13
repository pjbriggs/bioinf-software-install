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
echo Moving to $SAMTOOLS_DIR
cd $SAMTOOLS_DIR
echo -n Resetting CFLAGS in Makefile to add -fPIC...
sed -i 's/^CFLAGS=		.*/CFLAGS=		-g -Wall -O2 -fPIC #-m64 #-arch ppc/g' Makefile
echo done
echo -n Building in $SAMTOOLS_DIR...
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
echo -n Creating $INSTALL_DIR...
mkdir -p $INSTALL_DIR
echo done
echo Installing executables
for f in $(echo samtools bcftools/bcftools) ; do
  copy_file $f $INSTALL_DIR
done
echo Installing headers and libraries
for f in $(echo *.h) ; do
  copy_file $f $INSTALL_DIR
done
for f in $(echo *.a) ; do
  copy_file $f $INSTALL_DIR
done
cd ..
clean_up $TARGZ
##
#
