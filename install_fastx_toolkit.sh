#!/bin/sh
#
# Install fastx_toolkit and gtextutils
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
echo Build libgtextutils from $LIBGTEXTUTILS_TARGZ
echo Version $LIBGTEXTUTILS_VER
unpack_archive $LIBGTEXTUTILS_TARGZ
if [ ! -d $LIBGTEXTUTILS_DIR ] ; then
  echo ERROR no directory $LIBGTEXTUTILS_DIR found >&2
  exit 1
fi
echo -n Building in $LIBGTEXTUTILS_DIR...
cd $LIBGTEXTUTILS_DIR
./configure --prefix=$GTEXTUTILS_INSTALL_DIR >> build.log 2>&1
make >> build.log 2>&1
if [ $? -ne 0 ] ; then
  echo FAILED
  echo make failed for libgtextutils >&2
  exit 1
else
  echo done
fi
echo -n Installing libgtextutils in $GTEXTUTILS_INSTALL_DIR...
make install >> build.log 2>&1
echo done
cd ..
clean_up $LIBGTEXTUTILS_TARGZ
echo Build fastx_toolkit from $FASTX_TOOLKIT_TARGZ
echo Version $FASTX_TOOLKIT_VER
unpack_archive $FASTX_TOOLKIT_TARGZ
if [ ! -d $FASTX_TOOLKIT_DIR ] ; then
  echo ERROR no directory $FASTX_TOOLKIT_DIR found >&2
  exit 1
fi
echo -n Adding $GTEXTUTILS_INSTALL_DIR/lib to LD_LIBRARY_PATH...
prepend_path LD_LIBRARY_PATH $GTEXTUTILS_INSTALL_DIR/lib
echo done
echo -n Building in $FASTX_TOOLKIT_DIR...
cd $FASTX_TOOLKIT_DIR
./configure --prefix=$INSTALL_DIR GTEXTUTILS_CFLAGS="-I$GTEXTUTILS_INSTALL_DIR/include/gtextutils" GTEXTUTILS_LIBS=-lgtextutils >> build.log 2>&1
make >> build.log 2>&1
if [ $? -ne 0 ] ; then
  echo FAILED
  echo make failed for fastx_toolkit >&2
  exit 1
else
  echo done
fi
echo -n Installing fastx_toolkit in $INSTALL_DIR...
make install >> build.log 2>&1
echo done
cd ..
clean_up $FASTX_TOOLKIT_TARGZ
echo "#%Module1.0"
echo "## fastx_toolkit $FASTX_TOOLKIT_VER modulefile"
echo "prepend-path PATH            $INSTALL_DIR/bin"
echo "prepend-path LD_LIBRARY_PATH $GTEXTUTILS_INSTALL_DIR/lib"
echo 
##
#
