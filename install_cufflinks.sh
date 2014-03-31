#!/bin/sh
#
# Fetch and install cufflinks binaries
#
. $(dirname $0)/functions.sh
#
CUFFLINKS_VERSION=$1
INSTALL_DIR=$2
if [ -z "$CUFFLINKS_VERSION" ] || [ -z "$INSTALL_DIR" ] ; then
  echo Usage: $(basename $0) CUFFLINKS_VERSION INSTALL_DIR
  echo Downloads and installs cufflinks binaries to INSTALL_DIR/cufflinks/VERSION
  exit 1
fi
echo Install Cufflinks version $CUFFLINKS_VERSION
TGZ_FILE=cufflinks-${CUFFLINKS_VERSION}.Linux_x86_64.tar.gz
TGZ_URL=http://cufflinks.cbcb.umd.edu/downloads/$TGZ_FILE
if [ -f $TGZ_FILE ] ; then
  echo ERROR $TGZ_FILE already exists >&2
  exit 1
fi
wget_url $TGZ_URL
unpack_archive $TGZ_FILE
CUFFLINKS_DIR=$(package_dir $TGZ_FILE)
INSTALL_DIR=$(full_path $INSTALL_DIR)/cufflinks/$CUFFLINKS_VERSION
echo -n Creating $INSTALL_DIR...
mkdir -p $INSTALL_DIR
echo done
copy_contents $CUFFLINKS_DIR $INSTALL_DIR
clean_up $TGZ_FILE
echo "#%Module1.0"
echo "## cufflinks $CUFFLINKS_VERSION modulefile"
echo "prepend-path PATH            $INSTALL_DIR"
echo 
##
#


