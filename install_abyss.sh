#!/bin/sh
#
# Install ABYSS
#
# On Fedora 19 also need yum packages:
#
# sparsehash-devel
# boost & boost-devel
# openmpi & openmpi-devel
#
. $(dirname $0)/import_functions.sh
#
TARGZ=$1
INSTALL_DIR=$2
if [ -z "$TARGZ" ] || [ -z "$INSTALL_DIR" ] ; then
    echo Usage: $(basename $0) \[OPTIONS\] TARGZ INSTALL_DIR
    echo Installs ABYSS to INSTALL_DIR/abyss/VERSION
    exit 1
fi
ABYSS_DIR=$(package_dir $TARGZ)
ABYSS_VER=$(package_version $TARGZ)
INSTALL_DIR=$(full_path $INSTALL_DIR)/abyss/$ABYSS_VER
echo Build ABYSS from $TARGZ
echo Version $ABYSS_VER
BOOST_INCL=/usr/include/boost
echo -n Checking for $BOOST_INCL...
if [ ! -d "$BOOST_INCL" ] ; then
    echo FAILED
    echo ERROR $BOOST_INCL not found >&2
    exit 1
else
    echo ok
fi
SPARSEHASH_INCL=/usr/include/google/sparsehash
echo -n Checking for $SPARSEHASH_INCL...
if [ ! -d "$SPARSEHASH_INCL" ] ; then
    echo FAILED
    echo ERROR $SPARSEHASH_INCL not found >&2
    exit 1
else
    echo ok
fi
unpack_archive $TARGZ
if [ ! -d $ABYSS_DIR ] ; then
  echo ERROR no directory $ABYSS_DIR found >&2
  exit 1
fi
echo Moving to $ABYSS_DIR
cd $ABYSS_DIR
echo -n Running configure...
./configure --prefix=$INSTALL_DIR --enable-maxk=128 >> build.log 2>&1
if [ $? -ne 0 ] ; then
  echo FAILED
  echo ERROR make returned non-zero exit code >&2
  exit 1
else
  echo ok
fi
echo -n Running make...
make >> build.log 2>&1
if [ $? -ne 0 ] ; then
  echo FAILED
  echo ERROR make returned non-zero exit code >&2
  exit 1
else
  echo ok
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
  echo ok
fi
cd ..
clean_up $TARGZ
