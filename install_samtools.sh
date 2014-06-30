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
  echo Installs samtools and bcftools to INSTALL_DIR/samtools/VERSION
  exit 1
fi
SAMTOOLS_DIR=$(package_dir $TARGZ)
SAMTOOLS_VER=$(package_version $TARGZ)
INSTALL_DIR=$(full_path $INSTALL_DIR)/samtools/$SAMTOOLS_VER
echo Build samtools from $TARGZ
echo Version $SAMTOOLS_VER
unpack_archive $TARGZ
# Build samtools
echo Moving to $SAMTOOLS_DIR
cd $SAMTOOLS_DIR
echo -n Resetting CFLAGS in Makefile to add -fPIC...
sed -i 's/^CFLAGS=		.*/CFLAGS=		-g -Wall -O2 -fPIC #-m64 #-arch ppc/g' Makefile
echo done
do_make --log build.log
# Build bcftools
check_directory bcftools
echo Moving to bcftools
cd bcftools
do_make --log ../build.log
cd ..
# Install executables, headers and libraries
create_directory $INSTALL_DIR
echo Installing executables
copy_files samtools bcftools/bcftools $INSTALL_DIR
echo Installing headers and libraries
copy_files *.h $INSTALL_DIR
copy_files *.a $INSTALL_DIR
# Finish up
cd ..
clean_up $TARGZ
##
#
