#!/bin/sh
#
# Install MEME suite
#
# Known to work for MEME versions:
# - 4.8.1 (unpatched)
# - 4.9.1_2
# - 4.10.0_1
#
. $(dirname $0)/import_functions.sh
#
TARGZ=$1
INSTALL_DIR=$2
if [ -z "$TARGZ" ] || [ -z "$INSTALL_DIR" ] ; then
  echo Usage: $(basename $0) TARGZ INSTALL_DIR
  echo Installs MEME suite to INSTALL_DIR/meme/VERSION
  exit 1
fi
MEME_DIR=$(package_dir $TARGZ)
MEME_VER=$(echo $MEME_DIR | cut -d'_' -f2-)
MEME_PATCH=$(echo $MEME_DIR | cut -d'_' -f3)
if [ ! -z "$MEME_PATCH" ] ; then
  MEME_DIR=$(echo $MEME_DIR | cut -d'_' -f1-2)
fi
INSTALL_DIR=$(full_path $INSTALL_DIR)/meme/$MEME_VER
echo Build MEME suite from $TARGZ
echo -n Version $MEME_VER
if [ ! -z "$MEME_PATCH" ] ; then
  echo
else
  echo " (unpatched)"
fi
unpack_archive --no-package-dir-check $TARGZ
if [ ! -d $MEME_DIR ] ; then
  echo ERROR no directory $MEME_DIR found >&2
  exit 1
fi
echo Moving to $MEME_DIR
cd $MEME_DIR
echo -n Running configure...
./configure --enable-build-libxslt --enable-build-libxml2 --disable-web --prefix=$INSTALL_DIR >> build.log 2>&1
echo done
echo -n Running make...
make >> build.log 2>&1
if [ $? -ne 0 ] ; then
  echo FAILED
  echo ERROR make returned non-zero exit code >&2
  exit 1
else
  echo done
fi
echo -n Creating $INSTALL_DIR...
mkdir -p $INSTALL_DIR
echo done
echo -n Running make install...
make install >> build.log 2>&1
if [ $? -ne 0 ] ; then
  echo FAILED
  echo ERROR make install returned non-zero exit code >&2
  exit 1
else
  echo done
fi
cd ..
clean_up_dir $MEME_DIR
##
#
