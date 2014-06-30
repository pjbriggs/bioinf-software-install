#!/bin/sh
#
# Install ABYSS
#
# On Fedora 19 also need yum packages:
#
# sparsehash-devel
# boost & boost-devel
# openmpi & openmpi-devel
#
. $(dirname $0)/import_functions.sh
#
# Defaults
BOOST_INCL=/usr/include/boost
SPARSEHASH_INCL=/usr/include/google/sparsehash
MAX_KMER=128
#
# Command line
while [ $# -gt 2 ] ; do
    case "$1" in
	--with-boost)
	    shift
	    BOOST_INCL=$1
	    ;;
	--with-sparsehash)
	    shift
	    SPARSEHASH_INCL=$1
	    ;;
	--max-kmer)
	    shift
	    MAX_KMER=$1
	    ;;
	--*)
	    echo ERROR unrecognised option $1 >&2
	    exit 1
	    ;;
    esac
    shift
done
TARGZ=$1
INSTALL_DIR=$2
if [ -z "$TARGZ" ] || [ -z "$INSTALL_DIR" ] ; then
    echo Usage: $(basename $0) \[OPTIONS\] TARGZ INSTALL_DIR
    echo Installs ABYSS to INSTALL_DIR/abyss/VERSION
    echo --with-boost BOOST_INCL: set directory for boost headers
    echo --with-sparsehash SPARSEHASH_INCL: set directory for sparsehash headers
    echo --max-kmer LENGTH: set maximum kmer length \(default 128\)
    exit 1
fi
# Start
ABYSS_DIR=$(package_dir $TARGZ)
ABYSS_VER=$(package_version $TARGZ)
INSTALL_DIR=$(full_path $INSTALL_DIR)/abyss/$ABYSS_VER
echo Build ABYSS from $TARGZ
echo Version $ABYSS_VER
# Set up build log
LOG_FILE=$(pwd)/install.abyss.$ABYSS_VER.log
clean_up_file $LOG_FILE
# Check include directories exist
check_directory $BOOST_INCL
check_directory $SPARSEHASH_INCL
# Unpack source code
unpack_archive $TARGZ
echo Moving to $ABYSS_DIR
# Do build and install
cd $ABYSS_DIR
export CPPFLAGS="-I$SPARSEHASH_INCL"
do_configure --log $LOG_FILE \
    --with-boost=$BOOST_INCL \
    --prefix=$INSTALL_DIR \
    --enable-maxk=$MAX_KMER
do_make --log $LOG_FILE
create_directory $INSTALL_DIR
do_make --log $LOG_FILE install
# Finish up
cd ..
clean_up $TARGZ
##
#
