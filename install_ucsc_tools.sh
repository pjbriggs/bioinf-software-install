#!/bin/sh
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
echo Build ucsc-tools from $ZIP
echo Version $UCSCTOOLS_VER
unpack_archive --no-package-dir-check $ZIP
if [ ! -d $UCSCTOOLS_DIR ] ; then
  echo ERROR no directory $UCSCTOOLS_DIR found >&2
  exit 1
fi
echo Moving to $UCSCTOOLS_DIR
cd $UCSCTOOLS_DIR
# Set up the environment
echo -n Setting MACHTYPE...
export MACHTYPE=$(echo $MACHTYPE | cut -d"-" -f1)
echo $MACHTYPE
# Set MySQL variables
echo -n Setting MYSQLLIBS...
export MYSQLLIBS=$(mysql_config --libs)
echo $MYSQLLIBS
echo -n Setting MYSQLINC...
export MYSQLINC=$(mysql_config --include)
if [ ! -z "$(echo $MYSQLINC | grep '^-I')" ] ; then
    export MYSQLINC=$(echo $MYSQLINC | cut -c3-) # Remove leading -I
fi
echo $MYSQLINC
# Create the initial installation directory
echo -n Setting BINDIR...
export BINDIR=$(pwd)/bin/$MACHTYPE
echo $BINDIR
echo -n Making BINDIR...
mkdir -p $BINDIR
echo done
echo -n Making lib/$MACHTYPE...
mkdir -p lib/$MACHTYPE
echo done
echo -n Building in src...
cd src
make utils blatSuite >> ../build.log 2>&1
if [ $? -ne 0 ] ; then
    echo FAILED
    echo ERROR failed to build UCSC tools, see $UCSCTOOLS_DIR/build.log >&2
    exit 1
else
    echo done
fi
cd ..
# Copy executables to installation location
echo -n Copying UCSC tools executables to $INSTALL_DIR...
mkdir -p $INSTALL_DIR
cp $BINDIR/* $INSTALL_DIR
echo done
cd ..
echo Removing $UCSCTOOLS_DIR...
rm -rf $UCSCTOOLS_DIR
echo done
##
#
