#!/bin/bash
#
# Install mothur
#
# Works for 1.32.1
#           1.33.2
#
. $(dirname $0)/import_functions.sh
#
ZIP=$1
INSTALL_DIR=$2
if [ -z "$ZIP" ] || [ -z "$INSTALL_DIR" ] ; then
  echo Usage: $(basename $0) ZIP INSTALL_DIR
  echo Installs mothur to INSTALL_DIR/mothur/VERSION
  exit 1
fi
MOTHUR_DIR=Mothur.source
MOTHUR_VER=$(echo ${ZIP%.zip} | cut -d. -f2-)
INSTALL_DIR=$(full_path $INSTALL_DIR)/mothur/$MOTHUR_VER
echo Build mothur from $ZIP
echo Version $MOTHUR_VER
# Set up log file
LOG_FILE=$(pwd)/install.mothur.$MOTHUR_VER.log
clean_up_file $LOG_FILE
# Unpack
unpack_archive --no-package-dir-check $ZIP
check_directory $MOTHUR_DIR
echo -n Moving $MOTHUR_DIR to $MOTHUR_DIR.$MOTHUR_VER...
mv -f $MOTHUR_DIR $MOTHUR_DIR.$MOTHUR_VER
MOTHUR_DIR=$MOTHUR_DIR.$MOTHUR_VER
echo done
clean_up_dir __MACOSX
# Build Mothur
echo Moving to $MOTHUR_DIR
cd $MOTHUR_DIR
echo -n Updating makefile...
sed -i 's/^USECOMPRESSION ?= no/USECOMPRESSION ?= yes/' makefile
sed -i 's/TARGET_ARCH += -arch x86_64/#TARGET_ARCH += -arch x86_64/' makefile
sed -i 's/#CXXFLAGS +=/CXXFLAGS +=/' makefile
echo done
echo -n Updating uchime_src/mk...
sed -i 's/LINK_OPTS=-static/LINK_OPTS=/' uchime_src/mk
echo done
do_make --log $LOG_FILE
# Install files
create_directory $INSTALL_DIR
copy_files mothur uchime $INSTALL_DIR
cd ..
clean_up_dir $MOTHUR_DIR
echo "#%Module1.0"
echo "## mothur $MOTHUR_VER modulefile"
echo "prepend-path PATH            $INSTALL_DIR"
echo 
##
#
