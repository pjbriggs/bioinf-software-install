#!/bin/sh
#
# Install fastx_toolkit and gtextutils
#
# Works for:
# fastx_toolkit 0.0.14 & libgtextutils 0.7
# fastx_toolkit 0.0.13.2 & libgtextutils 0.6.1
#
. $(dirname $0)/import_functions.sh
#
FASTX_TOOLKIT_TARGZ=$1
LIBGTEXTUTILS_TARGZ=$2
INSTALL_DIR=$3
if [ -z "$FASTX_TOOLKIT_TARGZ" ] || [ -z "$LIBGTEXTUTILS_TARGZ" ] || [ -z "$INSTALL_DIR" ] ; then
  echo Usage: $(basename $0) FASTX_TOOLKIT_TARGZ LIBGTEXTUTILS_TARGZ INSTALL_DIR
  echo Builds fastx_toolkit and gtextutils from source and installs to INSTALL_DIR/fastx_toolkit/VERSION
  exit 1
fi
FASTX_TOOLKIT_DIR=$(package_dir $FASTX_TOOLKIT_TARGZ)
FASTX_TOOLKIT_VER=$(package_version $FASTX_TOOLKIT_TARGZ)
LIBGTEXTUTILS_DIR=$(package_dir $LIBGTEXTUTILS_TARGZ)
LIBGTEXTUTILS_VER=$(package_version $LIBGTEXTUTILS_TARGZ)
INSTALL_DIR=$(full_path $INSTALL_DIR)/fastx_toolkit/$FASTX_TOOLKIT_VER
GTEXTUTILS_INSTALL_DIR=$INSTALL_DIR/gtextutils-$LIBGTEXTUTILS_VER
# Set up build log
LOG_FILE=$(pwd)/install.fastx_toolkit.$FASTX_TOOLKIT_VER.log
clean_up_file $LOG_FILE
# Build libgtextutils
echo Build libgtextutils from $LIBGTEXTUTILS_TARGZ
echo Version $LIBGTEXTUTILS_VER
unpack_archive $LIBGTEXTUTILS_TARGZ
echo Moving to $LIBGTEXTUTILS_DIR
cd $LIBGTEXTUTILS_DIR
do_configure --log $LOG_FILE \
    --prefix=$GTEXTUTILS_INSTALL_DIR
do_make --log $LOG_FILE
do_make --log $LOG_FILE install
cd ..
clean_up $LIBGTEXTUTILS_TARGZ
# Build fastx_toolkit
echo Build fastx_toolkit from $FASTX_TOOLKIT_TARGZ
echo Version $FASTX_TOOLKIT_VER
unpack_archive $FASTX_TOOLKIT_TARGZ
echo -n Adding $GTEXTUTILS_INSTALL_DIR/lib to LD_LIBRARY_PATH...
prepend_path LD_LIBRARY_PATH $GTEXTUTILS_INSTALL_DIR/lib
echo done
echo Moving to $FASTX_TOOLKIT_DIR
cd $FASTX_TOOLKIT_DIR
do_configure --log $LOG_FILE \
    --prefix=$INSTALL_DIR \
    GTEXTUTILS_CFLAGS="-I$GTEXTUTILS_INSTALL_DIR/include/gtextutils" \
    GTEXTUTILS_LIBS=-lgtextutils
do_make --log $LOG_FILE
do_make --log $LOG_FILE install
cd ..
clean_up $FASTX_TOOLKIT_TARGZ
# Suggest module file
echo "#%Module1.0"
echo "## fastx_toolkit $FASTX_TOOLKIT_VER modulefile"
echo "prepend-path PATH            $INSTALL_DIR/bin"
echo "prepend-path LD_LIBRARY_PATH $GTEXTUTILS_INSTALL_DIR/lib"
echo 
##
#
