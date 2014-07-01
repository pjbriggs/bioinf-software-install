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
PYTHON_DIR=$(package_dir $TARGZ)
PYTHON_VER=$(package_version $TARGZ)
INSTALL_DIR=$(full_path $INSTALL_DIR)/python/$PYTHON_VER
echo Build python from $TARGZ
echo Version $PYTHON_VER
# Set up log file
LOG_FILE=$(pwd)/install.python.$PYTHON_VER.log
clean_up_file $LOG_FILE
# Build and install Python
unpack_archive $TARGZ
echo Moving to $PYTHON_DIR
cd $PYTHON_DIR
do_configure --log $LOG_FILE --prefix=$INSTALL_DIR
do_make --log $LOG_FILE
create_directory $INSTALL_DIR
do_make --log $LOG_FILE install
# Install ez_setup and pip
EZ_SETUP_URL=http://peak.telecommunity.com/dist/ez_setup.py
wget_url $EZ_SETUP_URL
if [ ! -f ez_setup.py ] ; then
  echo Failed to download ez_setup.py >&2
  exit 1
fi
PYTHON_BIN=$INSTALL_DIR/bin
echo -n Installing easy_install...
$PYTHON_BIN/python ez_setup.py >>$LOG_FILE 2>&1
if [ $? -ne 0 ] ; then
    echo FAILED
    echo ez_setup.py exited with non-zero status >&2
    exit 1
fi
echo done
echo -n Installing pip...
$PYTHON_BIN/easy_install pip >>$LOG_FILE 2>&1
echo done
# Finish up
cd ..
clean_up $TARGZ
##
#
