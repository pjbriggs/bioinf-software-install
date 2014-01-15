#!/bin/sh -e
#
# Build perl
#
TARGZ=$1
INSTALL_DIR=$2
if [ -z "$TARGZ" ] || [ -z "$INSTALL_DIR" ] ; then
  echo Usage $(basename $0) TARGZ INSTALL_DIR
  exit 1
fi
#
TARGZ_BASE=$(basename $TARGZ)
PERL_DIR=${TARGZ_BASE%.tar.gz}
PERL_VER=$(echo $PERL_DIR | cut -d"-" -f2)
echo Build perl from $TARGZ
echo Version $PERL_VER
echo -n Unpacking...
tar -zxf $TARGZ
echo done
if [ ! -d $PERL_DIR ] ; then
  echo ERROR no directory $PERL_DIR found >&2
  exit 1
fi
echo -n Building in $PERL_DIR...
cd $PERL_DIR
./Configure -des -Dprefix=$INSTALL_DIR > build.log 2>&1
make > build.log 2>&1
echo done
echo -n Installing to $INSTALL_DIR...
mkdir -p $INSTALL_DIR
make install > install.log 2>&1
echo done
##
#