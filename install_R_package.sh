#!/bin/sh
#
# Install R package
#
# Script for installing an R package into an arbitrary location
# using an arbitrary R version, using either a local tar.gz file
# or via CRAN
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
if [ -f "$(full_path $PACKAGE)" ] ; then
    PACKAGE=$(full_path $PACKAGE)
    echo Found local file $PACKAGE
    R_REPO=NULL
    EXTRA_ARGS=",type=\"source\""
else
    echo Attempting to fetch $PACKAGE from CRAN
    R_REPO=\"http://cran.ma.imperial.ac.uk/\"
    EXTRA_ARGS=
fi
echo Using R from $(dirname $R_EXE)
echo CRAN repo set to $R_REPO
echo Installing under $INSTALL_DIR
if [ ! -d "$INSTALL_DIR" ] ; then
    echo -n Making $INSTALL_DIR...
    mkdir -p $INSTALL_DIR
    echo done
fi
echo -n Prepending $INSTALL_DIR to R_LIBS...
prepend_path R_LIBS $INSTALL_DIR
echo done
echo -n Running install.packages in R...
$R_EXE --vanilla &> $(package_dir $PACKAGE).install.log <<EOF
install.packages("$PACKAGE",lib="$INSTALL_DIR",repos=$R_REPO$EXTRA_ARGS)
q()
EOF
echo done
##
#
