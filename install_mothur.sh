#!/bin/sh
#
# Install mothur
#
. $(dirname $0)/functions.sh
#
ZIP=$1
INSTALL_DIR=$2
if [ -z "$ZIP" ] || [ -z "$INSTALL_DIR" ] ; then
  echo Usage: $(basename $0) ZIP INSTALL_DIR
  echo Installs mothur to INSTALL_DIR/mothur/VERSION
  exit 1
fi
MOTHUR_DIR=Mothur.source
MOTHUR_VER=$(echo ${ZIP%.zip} | cut -d. -f2-)
INSTALL_DIR=$(full_path $INSTALL_DIR)/mothur/$MOTHUR_VER
echo Build mothur from $TARGZ
echo Version $SAMTOOLS_VER
unpack_archive --no-package-dir-check $ZIP
if [ ! -d $MOTHUR_DIR ] ; then
  echo ERROR no directory $MOTHUR_DIR found >&2
  exit 1
fi
echo -n Moving into $MOTHUR_DIR to $MOTHUR_DIR.$MOTHUR_VER
mv -f $MOTHUR_DIR $MOTHUR_DIR.$MOTHUR_VER
MOTHUR_DIR=$MOTHUR_DIR.$MOTHUR_VER
echo done
clean_up_dir __MACOSX
echo Moving to $MOTHUR_DIR...
cd $MOTHUR_DIR
echo -n Updating makefile...
sed -i 's/^USECOMPRESSION ?= no/USECOMPRESSION ?= yes/' makefile
sed -i 's/TARGET_ARCH += -arch x86_64/#TARGET_ARCH += -arch x86_64/' makefile
sed -i 's/#CXXFLAGS +=/CXXFLAGS +=/' makefile
echo done
echo -n Updating uchime_src/mk...
sed -i 's/LINK_OPTS=-static/LINK_OPTS=/' uchime_src/mk
echo done
echo -n Running make...
make > ../install.mothur.$MOTHUR_VER.log 2>&1
if [ $? -ne 0 ] ; then
  echo FAILED
  echo See log file install.mothur.$MOTHUR_VER.log for more information
  echo make failed for mothur >&2
  exit 1
else
  echo done
  clean_up_file ../install.mothur.$MOTHUR_VER.log
fi
cd ..
echo -n Creating $INSTALL_DIR...
mkdir -p $INSTALL_DIR
echo done
copy_file $MOTHUR_DIR/mothur $INSTALL_DIR
copy_file $MOTHUR_DIR/uchime $INSTALL_DIR
clean_up_dir $MOTHUR_DIR
echo "#%Module1.0"
echo "## mothur $MOTHUR_VER modulefile"
echo "prepend-path PATH            $INSTALL_DIR"
echo 
##
#
