#!/bin/sh
#
# Fetch and install bowtie binaries
#
. $(dirname $0)/functions.sh
#
BOWTIE_VERSION=$1
INSTALL_DIR=$2
if [ -z "$BOWTIE_VERSION" ] || [ -z "$INSTALL_DIR" ] ; then
  echo Usage: $(basename $0) BOWTIE_VERSION INSTALL_DIR
  echo Downloads and installs bowtie binaries to INSTALL_DIR/bowtie\[2\]/VERSION
  exit 1
fi
echo Install Bowtie version $BOWTIE_VERSION
echo -n Determine whether bowtie or bowtie2...
BOWTIE=bowtie$(echo $BOWTIE_VERSION | cut -d. -f1 | grep -v "^1$")
echo $BOWTIE
ZIP_FILE=${BOWTIE}-${BOWTIE_VERSION}-linux-x86_64.zip
ZIP_URL=http://sourceforge.net/projects/bowtie-bio/files/$BOWTIE/$BOWTIE_VERSION/$ZIP_FILE
if [ -f $ZIP_FILE ] ; then
  echo ERROR $ZIP_FILE already exists >&2
  exit 1
fi
wget_url $ZIP_URL
unpack_archive --no-package-dir-check $ZIP_FILE
BOWTIE_DIR=${BOWTIE}-$BOWTIE_VERSION
if [ ! -d $BOWTIE_DIR ] ; then
  echo ERROR no directory $BOWTIE_DIR >&2
fi
INSTALL_DIR=$(full_path $INSTALL_DIR)/$BOWTIE/$BOWTIE_VERSION
echo -n Creating $INSTALL_DIR...
mkdir -p $INSTALL_DIR
echo done
copy_contents $BOWTIE_DIR $INSTALL_DIR
clean_up_dir $BOWTIE_DIR
echo "#%Module1.0"
echo "## $BOWTIE $BOWTIE_VERSION modulefile"
echo "prepend-path PATH            $INSTALL_DIR"
echo 
##
#


