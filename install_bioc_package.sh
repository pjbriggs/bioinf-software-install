#!/bin/sh
#
# Install Bioconductor package
#
# Script for installing a Bioconductor package into an arbitrary
# location using an arbitrary R version
#
. $(dirname $0)/functions.sh
#
# Main script
if [ "$1" == "--force" ] ; then
    force_install=yes
    shift
fi
R_EXE=$1
PACKAGE=$2
INSTALL_DIR=$3
if [ -z "$R_EXE" ] || [ -z "$PACKAGE" ] || [ -z "$INSTALL_DIR" ] ; then
  echo Usage: $(basename $0) \[--force\] R_EXE PACKAGE INSTALL_DIR
  exit 1
fi
R_EXE=$(full_path $R_EXE)
R_VER=$(R_version $R_EXE)
INSTALL_DIR=$(full_path $INSTALL_DIR)/$R_VER
PACKAGE_NAME=$(package_dir $PACKAGE)
echo "## Install $(basename $PACKAGE) ##"
echo Using R from $(dirname $R_EXE)
echo R version $R_VER
echo Installing under $INSTALL_DIR
if [ ! -d "$INSTALL_DIR" ] ; then
    echo -n Making $INSTALL_DIR...
    mkdir -p $INSTALL_DIR
    echo done
fi
echo -n Prepending $INSTALL_DIR to R_LIBS...
prepend_path R_LIBS $INSTALL_DIR
echo done
echo -n Checking if $PACKAGE_NAME is already installed...
if [ ! -z "$(R_package_installed $R_EXE $PACKAGE_NAME)" ] ; then
    echo yes
    if [ -z "$force_install" ] ; then
	echo $PACKAGE_NAME already installed, use --force to override
	exit
    fi
    echo Reinstalling $PACKAGE_NAME
else
    echo no
fi
echo -n Running biocLite.R in R...
$R_EXE --vanilla &> $PACKAGE_NAME.$R_VER.install.log <<EOF
source("http://bioconductor.org/biocLite.R")
biocLite()
biocLite("$PACKAGE",lib="$INSTALL_DIR")
q()
EOF
echo done
echo -n Checking $PACKAGE_NAME was installed...
if [ ! -z "$(R_package_installed $R_EXE $PACKAGE_NAME)" ] ; then
    echo ok
else
    echo FAILED
    exit 1
fi
##
#
