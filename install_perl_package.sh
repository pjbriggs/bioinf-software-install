#!/bin/bash
#
# Install Perl package
#
# Script for installing a Perl package into an arbitrary location
# using an arbitrary Perl version, using either a local tar.gz file
# or via CPAN
#
. $(dirname $0)/import_functions.sh
#
# Main script
if [ "$1" == "--force" ] ; then
    force_install=yes
    shift
fi
PERL_EXE=$1
PACKAGE=$2
INSTALL_DIR=$3
if [ -z "$PERL_EXE" ] || [ -z "$PACKAGE" ] || [ -z "$INSTALL_DIR" ] ; then
  echo Usage: $(basename $0) PERL_EXE PACKAGE INSTALL_DIR
  exit 1
fi
PERL_EXE=$(full_path $PERL_EXE)
PERL_VER=$(perl_version $PERL_EXE)
INSTALL_DIR=$(full_path $INSTALL_DIR)/$PERL_VER
PACKAGE_NAME=$(package_name $PACKAGE)
echo "## Install $PACKAGE_NAME ##"
echo Using Perl from $(dirname $PERL_EXE)
echo Perl version $PERL_VER
echo Installing under $INSTALL_DIR
if [ -d "$INSTALL_DIR" ] ; then
  echo -n Making $INSTALL_DIR...
  mkdir -p $INSTALL_DIR
  echo done
fi
echo -n Prepending $(dirname $PERL_EXE) to PATH...
prepend_path PATH $(dirname $PERL_EXE)
echo done
echo -n Prepending $INSTALL_DIR/lib/perl5 to PERL5LIB...
prepend_path PERL5LIB $INSTALL_DIR/lib/perl5
echo done
echo -n Checking for cpanm...
CPANM=$(dirname $PERL_EXE)/cpanm
if [ ! -x "$CPANM" ] ; then
  echo missing
  install_cpanminus $PERL_EXE
else
  echo ok
fi
install_perl_package $PERL_EXE $PACKAGE $INSTALL_DIR
##
#
