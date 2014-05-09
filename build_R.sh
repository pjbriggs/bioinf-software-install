#!/bin/sh
#
# Build R
#
. $(dirname $0)/import_functions.sh
#
TARGZ=$1
INSTALL_DIR=$2
if [ -z "$TARGZ" ] || [ -z "$INSTALL_DIR" ] ; then
  echo Usage: $(basename $0) TARGZ INSTALL_DIR
  echo Installs R to INSTALL_DIR/R/VERSION
  exit 1
fi
R_DIR=$(package_dir $TARGZ)
R_VER=$(package_version $TARGZ)
INSTALL_DIR=$(full_path $INSTALL_DIR)/R/$R_VER
echo Build R from $TARGZ
echo Version $R_VER
unpack_archive $TARGZ
if [ ! -d $R_DIR ] ; then
  echo ERROR no directory $R_DIR found >&2
  exit 1
fi
echo -n Building in $R_DIR...
cd $R_DIR
./configure --prefix=$INSTALL_DIR > build.log 2>&1
if [ $? -ne 0 ] ; then
    echo FAILED
    echo configure returned non-zero exit status >&2
    exit 1
fi
make >> build.log 2>&1
if [ $? -ne 0 ] ; then
    echo FAILED
    echo make returned non-zero exit status >&2
    exit 1
else
    echo done
fi
echo -n Installing to $INSTALL_DIR...
mkdir -p $INSTALL_DIR
make install > install.log 2>&1
if [ $? -ne 0 ] ; then
    echo FAILED
    echo make install returned non-zero exit status >&2
    exit 1
else
    echo done
fi
cd ..
clean_up $TARGZ
##
#
