#!/bin/sh
#
# Install R package
#
# Script for installing an R package into an arbitray local using an
# arbitrary R version, using either a local tar.gz file or via CRAN
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
CRAN_REPO="http://cran.ma.imperial.ac.uk/"
echo "## Install $PACKAGE_NAME ##"
echo Using R from $(dirname $R_EXE)
echo CRAN repo set to $CRAN_REPO
echo Installing under $INSTALL_DIR
if [ ! -d "$INSTALL_DIR" ] ; then
    echo -n Making $INSTALL_DIR...
    mkdir -p $INSTALL_DIR
    echo done
fi
echo -n Prepending $INSTALL_DIR to R_LIBS...
prepend_path R_LIBS $INSTALL_DIR
echo done
$R_EXE --vanilla &> $PACKAGE_NAME.install.log <<EOF
install.packages("$PACKAGE",lib="$INSTALL_DIR",repos="$CRAN_REPO")
q()
EOF
##clean_up $TARGZ
##
#

