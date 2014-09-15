#!/bin/sh
#
# Install samtools
# Works for 0.1.18
#           0.1.19
#
. $(dirname $0)/import_functions.sh
#
TARZ=$1
INSTALL_DIR=$2
if [ -z "$TARZ" ] || [ -z "$INSTALL_DIR" ] ; then
  echo Usage: $(basename $0) TARZ INSTALL_DIR
  echo Installs samtools to INSTALL_DIR/samtools/VERSION
  echo \(nb samtools \< 1.0 includes bcftools\)
  exit 1
fi
SAMTOOLS_DIR=$(package_dir $TARZ)
SAMTOOLS_VER=$(package_version $TARZ)
INSTALL_DIR=$(full_path $INSTALL_DIR)/samtools/$SAMTOOLS_VER
echo Build samtools from $TARZ
echo Version $SAMTOOLS_VER
unpack_archive $TARZ
# Set up build log
LOG_FILE=$(pwd)/install.samtools.$SAMTOOLS_VER.log
clean_up_file $LOG_FILE
echo Moving to $SAMTOOLS_DIR
cd $SAMTOOLS_DIR
# Check major version
MAJOR_VERSION=$(echo $SAMTOOLS_VER | cut -d"." -f1)
echo Major version: $MAJOR_VERSION
if [ $MAJOR_VERSION -eq 0 ] ; then
  # Old-style pre-version 1.0 build
  echo NB build includes bcftools
  # Build samtools
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
else
  # Build for version 1.0
  do_make --log $LOG_FILE
  # Install
  create_directory $INSTALL_DIR
  do_make --log $LOG_FILE prefix=$INSTALL_DIR install
fi
# Finish up
cd ..
clean_up $TARZ
##
#
