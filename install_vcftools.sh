#!/bin/bash
#
# Install vcftools
#
# Used for version 0.1.12a
#
. $(dirname $0)/import_functions.sh
#
TARGZ=$1
INSTALL_DIR=$2
if [ -z "$TARGZ" ] || [ -z "$INSTALL_DIR" ] ; then
  echo Usage: $(basename $0) TARGZ INSTALL_DIR
  echo Installs vcftools to INSTALL_DIR/vcftools/VERSION
  exit 1
fi
VCFTOOLS_DIR=$(package_dir $TARGZ)
VCFTOOLS_VER=$(echo $VCFTOOLS_DIR | cut -d"_" -f2)
INSTALL_DIR=$(full_path $INSTALL_DIR)/vcftools/$VCFTOOLS_VER
echo Build vcftools from $TARGZ
echo Version $VCFTOOLS_VER
unpack_archive $TARGZ
# Set up build log
LOG_FILE=$(pwd)/install.vcftools.$VCFTOOLS_VER.log
clean_up_file $LOG_FILE
# Build vcftools
echo Moving to $VCFTOOLS_DIR
cd $VCFTOOLS_DIR
do_make --log $LOG_FILE
# Install executables
create_directory $INSTALL_DIR/bin
echo Installing executables
copy_files --exe bin/* $INSTALL_DIR/bin
# Install perl modules
create_directory $INSTALL_DIR/perl
echo Installing perl scripts and modules
copy_files --exe perl/* $INSTALL_DIR/perl
copy_files perl/*.pm $INSTALL_DIR/perl
create_directory $INSTALL_DIR/lib
echo Installing perl libraries from lib
copy_contents lib $INSTALL_DIR/lib
# Install man pages
create_directory $INSTALL_DIR/man
copy_contents bin/man $INSTALL_DIR/man
# Install examples
create_directory $INSTALL_DIR/examples
copy_contents examples $INSTALL_DIR/examples
# Finish up
cd ..
clean_up $TARGZ
# Set up information
echo "#%Module1.0"
echo "## vcftools $VCFTOOLS_VER modulefile"
echo "prepend-path PATH            $INSTALL_DIR/bin"
echo "prepend-path PATH            $INSTALL_DIR/perl"
echo "prepend-path PERL5LIB        $INSTALL_DIR/lib"
echo "prepend-path PERL5LIB        $INSTALL_DIR/lib/site_perl"
echo 
##
#
