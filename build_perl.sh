#!/bin/sh -e
#
# Build perl
#
. $(dirname $0)/functions.sh
#
TARGZ=$1
INSTALL_DIR=$2
if [ -z "$TARGZ" ] || [ -z "$INSTALL_DIR" ] ; then
  echo Usage: $(basename $0) TARGZ INSTALL_DIR
  echo Installs perl to INSTALL_DIR/perl/VERSION
  exit 1
fi
#
PERL_DIR=$(package_dir $TARGZ)
PERL_VER=$(package_version $TARGZ)
INSTALL_DIR=$(full_path $INSTALL_DIR)/perl/$PERL_VER
echo Build perl from $TARGZ
echo Version $PERL_VER
unpack_archive $TARGZ
if [ ! -d $PERL_DIR ] ; then
  echo ERROR no directory $PERL_DIR found >&2
  exit 1
fi
echo -n Building in $PERL_DIR...
cd $PERL_DIR
./Configure -des -Dprefix=$INSTALL_DIR > build.log 2>&1
make >> build.log 2>&1
echo done
echo -n Installing to $INSTALL_DIR...
mkdir -p $INSTALL_DIR
make install > install.log 2>&1
echo done
cd ..
clean_up $TARGZ
##
#
