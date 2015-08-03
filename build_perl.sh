#!/bin/bash -e
#
# Build perl
#
. $(dirname $0)/import_functions.sh
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
LOG_FILE=$(pwd)/install.perl.$PERL_VER.log
echo Build perl from $TARGZ
echo Version $PERL_VER
unpack_archive $TARGZ
echo Moving to $PERL_DIR
cd $PERL_DIR
echo -n Running perl Configure...
./Configure -des -Dprefix=$INSTALL_DIR >$LOG_FILE 2>&1
echo done
do_make --log $LOG_FILE
create_directory $INSTALL_DIR
do_make --log $LOG_FILE install
install_cpanminus $INSTALL_DIR/bin/perl
cd ..
clean_up $TARGZ
##
#
