#!/bin/sh
#
# Build python
#
. $(dirname $0)/import_functions.sh
#
TARGZ=$1
INSTALL_DIR=$2
if [ -z "$TARGZ" ] || [ -z "$INSTALL_DIR" ] ; then
  echo Usage: $(basename $0) TARGZ INSTALL_DIR
  echo Installs python to INSTALL_DIR/python/VERSION
  exit 1
fi
#
PYTHON_DIR=$(package_dir $TARGZ)
PYTHON_VER=$(package_version $TARGZ)
INSTALL_DIR=$(full_path $INSTALL_DIR)/python/$PYTHON_VER
echo Build python from $TARGZ
echo Version $PYTHON_VER
echo "## BUILD AND INSTALL PYTHON ##"
unpack_archive $TARGZ
if [ ! -d $PYTHON_DIR ] ; then
  echo ERROR no directory $PYTHON_DIR found >&2
  exit 1
fi
echo -n Building in $PYTHON_DIR...
cd $PYTHON_DIR
./configure --prefix=$INSTALL_DIR > build.log 2>&1
make >> build.log 2>&1
echo done
echo -n Installing to $INSTALL_DIR...
mkdir -p $INSTALL_DIR
make install > install.log 2>&1
echo done
echo "## INSTALL EASY_INSTALL/PIP ##"
EZ_SETUP_URL=http://peak.telecommunity.com/dist/ez_setup.py
wget_url $EZ_SETUP_URL
if [ ! -f ez_setup.py ] ; then
  echo Failed to download ez_setup.py >&2
  exit 1
fi
PYTHON_BIN=$INSTALL_DIR/bin
echo -n Installing easy_install...
$PYTHON_BIN/python ez_setup.py >> install.log 2>&1
echo done
echo -n Installing pip...
$PYTHON_BIN/easy_install pip >> install.log 2>&1
echo done
cd ..
clean_up $TARGZ
##
#
