#!/bin/sh
#
# Install samtools
# Works for 0.1.18
#           0.1.19
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
# Set up build log
LOG_FILE=$(pwd)/install.samtools.$SAMTOOLS_VER.log
clean_up_file $LOG_FILE
# Build samtools
echo Moving to $SAMTOOLS_DIR
cd $SAMTOOLS_DIR
echo -n Resetting CFLAGS in Makefile to add -fPIC...
sed -i 's/^CFLAGS=		.*/CFLAGS=		-g -Wall -O2 -fPIC #-m64 #-arch ppc/g' Makefile
echo done
do_make --log $LOG_FILE
# Build bcftools
check_directory bcftools
echo Moving to bcftools
cd bcftools
do_make --log $LOG_FILE
cd ..
# Install executables, headers and libraries
create_directory $INSTALL_DIR
echo Installing executables
copy_files samtools bcftools/bcftools bcftools/vcfutils.pl $INSTALL_DIR
echo Installing headers and libraries
copy_files *.h $INSTALL_DIR
copy_files *.a $INSTALL_DIR
# Finish up
cd ..
clean_up $TARGZ
##
#
