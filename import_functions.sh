#!/bin/bash
#
# Import shell library functions
_srcdir=$(dirname ${BASH_SOURCE[0]})
_libs="modulesque.sh functions.sh"
for _lib in $_libs ; do
    if [ ! -f $_srcdir/$_lib ] ; then
	echo Missing $_srcdir/$_lib
    else
	. $_srcdir/$_lib
    fi
done
_srcdir=
##
#
