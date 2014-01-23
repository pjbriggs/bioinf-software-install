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
R_EXE=$1
PACKAGE=$2
INSTALL_DIR=$3
if [ -z "$R_EXE" ] || [ -z "$PACKAGE" ] || [ -z "$INSTALL_DIR" ] ; then
  echo Usage: $(basename $0) R_EXE PACKAGE INSTALL_DIR
  exit 1
fi
R_EXE=$(full_path $R_EXE)
INSTALL_DIR=$(full_path $INSTALL_DIR)
echo "## Install $(basename $PACKAGE) ##"
echo Using R from $(dirname $R_EXE)
echo Installing under $INSTALL_DIR
if [ ! -d "$INSTALL_DIR" ] ; then
    echo -n Making $INSTALL_DIR...
    mkdir -p $INSTALL_DIR
    echo done
fi
echo -n Prepending $INSTALL_DIR to R_LIBS...
prepend_path R_LIBS $INSTALL_DIR
echo done
echo -n Running biocLite.R in R...
$R_EXE --vanilla &> $(package_dir $PACKAGE).install.log <<EOF
source("http://bioconductor.org/biocLite.R")
biocLite()
biocLite("$PACKAGE",lib="$INSTALL_DIR")
q()
EOF
echo done
##
#
