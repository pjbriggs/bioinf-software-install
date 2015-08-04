#!/bin/bash
#
# Install UCSC tools (AKA Kent tools)
#
. $(dirname $0)/import_functions.sh
#
ZIP=$1
INSTALL_DIR=$2
if [ -z "$ZIP" ] || [ -z "$INSTALL_DIR" ] ; then
  echo Usage: $(basename $0) ZIP INSTALL_DIR
  echo Installs UCSC tools to INSTALL_DIR/ucsc-tools/VERSION
  exit 1
fi
# Unpack the archive
UCSCTOOLS_DIR=kent # always unpacks into "kent"
UCSCTOOLS_VER=$(echo $ZIP | cut -d"." -f2)
INSTALL_DIR=$(full_path $INSTALL_DIR)/ucsc-tools/$UCSCTOOLS_VER
LOG_FILE=$(pwd)/install.ucsc_tools.$UCSCTOOLS_VER.log
clean_up_file $LOG_FILE
echo Build ucsc-tools from $ZIP
echo Version $UCSCTOOLS_VER
unpack_archive --no-package-dir-check $ZIP
check_directory $UCSCTOOLS_DIR
echo -n Moving $UCSCTOOLS_DIR to $UCSCTOOLS_DIR.$UCSCTOOLS_VER...
mv -f $UCSCTOOLS_DIR $UCSCTOOLS_DIR.$UCSCTOOLS_VER
echo done
UCSCTOOLS_DIR=$UCSCTOOLS_DIR.$UCSCTOOLS_VER
echo Moving to $UCSCTOOLS_DIR
cd $UCSCTOOLS_DIR
# Set up the environment
set_env_var MACHTYPE $(echo $MACHTYPE | cut -d"-" -f1)
# Set MySQL variables
check_program mysql_config
set_env_var MYSQLLIBS $(mysql_config --libs)
set_env_var MYSQLINC $(mysql_config --include)
if [ ! -z "$(echo $MYSQLINC | grep '^-I')" ] ; then
    set_env_var MYSQLINC $(echo $MYSQLINC | cut -c3-) # Remove leading -I
fi
# Create the initial installation directory
set_env_var BINDIR $(pwd)/bin/$MACHTYPE
create_directory $BINDIR
create_directory lib/$MACHTYPE
# Build
echo Moving to src
cd src
do_make --log $LOG_FILE utils userApps blatSuite
cd ..
# Copy executables to installation location
echo Copying UCSC tools executables to $INSTALL_DIR
create_directory $INSTALL_DIR
copy_files $BINDIR/* $INSTALL_DIR
cd ..
clean_up_dir $UCSCTOOLS_DIR
##
#
