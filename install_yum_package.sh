#!/bin/sh
#
# Install yum package
#
# Main script
PACKAGE=$1
if [ -z "$PACKAGE" ] ; then
  echo Usage: $(basename $0) PACKAGE
  exit 1
fi
echo "## Install $PACKAGE ##"
echo -n Yum installing $PACKAGE...
yum install -y $PACKAGE &> $PACKAGE.yum.log
if [ $? -eq 0 ] ; then
    echo ok
else
    echo FAILED
    exit 1
fi
##
#
