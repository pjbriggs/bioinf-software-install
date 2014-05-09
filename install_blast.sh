#!/bin/sh
#
# Fetch and install NCBI blast+ binaries
#
. $(dirname $0)/import_functions.sh
#
if [ "$1" == "--force" ] ; then
    force_install=yes
    shift
fi
BLAST_VERSION=$1
INSTALL_DIR=$2
if [ -z "$BLAST_VERSION" ] || [ -z "$INSTALL_DIR" ] ; then
  echo Usage: $(basename $0) \[--force\] BLAST_VERSION INSTALL_DIR
  echo Downloads and installs NCBI Blast+ binaries to INSTALL_DIR/ncbi-blast/VERSION
  exit 1
fi
BLAST_VERSION=$(echo $BLAST_VERSION | tr -d '+')
echo Install NCBI Blast version ${BLAST_VERSION}+
BASE_URL=ftp://ftp.ncbi.nlm.nih.gov/blast/executables/blast+/${BLAST_VERSION}
TARGZ_FILE=ncbi-blast-${BLAST_VERSION}+-x64-linux.tar.gz
MD5_FILE=ncbi-blast-${BLAST_VERSION}+-x64-linux.tar.gz.md5
TARGZ_URL=${BASE_URL}/$TARGZ_FILE
MD5_URL=${BASE_URL}/$MD5_FILE
if [ -f $TARGZ_FILE ] ; then
  if [ -z "$force_install" ] ; then
    echo ERROR $TARGZ_FILE already exists >&2
    exit 1
  else
    echo WARNING $TARGZ_FILE already exists
  fi
fi
wget_url $TARGZ_URL
wget_url $MD5_URL
if [ ! -f $MD5_FILE ] ; then
  if [ -z "$force_install" ] ; then
    echo ERROR failed to download MD5 file, use '--force' to override >&2
    exit 1
  else
    echo WARNING no MD5 file, proceeding anyway
  fi
else
    echo -n Checking MD5 checksum...
    md5sum -c $MD5_FILE
    if [ $? -ne 0 ] ; then
	if [ -z "$force_install" ] ; then
	    echo ERROR MD5 check failed, use '--force' to override >&2
	    exit 1
	else
	    echo WARNING MD5 check failed, proceeding anyway
	fi
    fi
fi
unpack_archive --no-package-dir-check $TARGZ_FILE
BLAST_DIR=ncbi-blast-${BLAST_VERSION}+
if [ ! -d $BLAST_DIR ] ; then
  echo ERROR no directory $BLAST_DIR >&2
fi
INSTALL_DIR=$(full_path $INSTALL_DIR)/ncbi-blast/${BLAST_VERSION}+
echo -n Creating $INSTALL_DIR...
mkdir -p $INSTALL_DIR
echo done
copy_contents $BLAST_DIR $INSTALL_DIR
clean_up_dir $BLAST_DIR
echo "#%Module1.0"
echo "## ncbi-blast ${BLAST_VERSION}+ modulefile"
echo "prepend-path PATH            $INSTALL_DIR/bin"
echo 
##
#


