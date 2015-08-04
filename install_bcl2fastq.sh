#!/bin/bash
#
# Install Illumina's bcl2fastq software
#
# Works for 1.84
#
. $(dirname $0)/import_functions.sh
#
TARBZ2=$1
INSTALL_DIR=$2
if [ -z "$TARBZ2" ] || [ -z "$INSTALL_DIR" ] ; then
  echo Usage: $(basename $0) TARBZ2 INSTALL_DIR
  echo Installs bcl2fastq suite to INSTALL_DIR/bcl2fastq/VERSION
  exit 1
fi
BCL2FASTQ_VER=$(package_version $TARBZ2)
INSTALL_DIR=$(full_path $INSTALL_DIR)/bcl2fastq/$BCL2FASTQ_VER
echo Build bcl2fastq from $TARBZ2
echo Version $BCL2FASTQ_VER
# Set up log file
LOG_FILE=$(pwd)/install.bcl2fastq.$BCL2FASTQ_VER.log
clean_up_file $LOG_FILE
# Unpack
unpack_archive --no-package-dir-check $TARBZ2
case $BCL2FASTQ_VER in
    1.8.3)
	BCL2FASTQ_DIR=BclToFastq
	;;
    1.8.4)
	BCL2FASTQ_DIR=bcl2fastq
	;;
    *)
	echo Unsupported version: $BCL2FASTQ_VER >&2
	exit 1
esac
check_directory $BCL2FASTQ_DIR
echo -n Moving $BCL2FASTQ_DIR to $BCL2FASTQ_DIR-$BCL2FASTQ_VER...
mv -f $BCL2FASTQ_DIR $BCL2FASTQ_DIR-$BCL2FASTQ_VER
BCL2FASTQ_DIR=$(full_path $BCL2FASTQ_DIR-$BCL2FASTQ_VER)
echo done
# Patch for overloading function (needed for FC19 with Boost 1.53)
# See # http://stackoverflow.com/questions/10827542/unresolved-overloaded-function-type-for-fspathstring
echo -n Patching src/c++/lib/demultiplex/BclDemultiplexer.cpp...
cd $BCL2FASTQ_DIR
patch -p1 1>$LOG_FILE 2>&1 <<EOF
--- BclToFastq/src/c++/lib/demultiplex/BclDemultiplexer.cpp	2012-01-31 15:48:40.000000
000 +0000
+++ BclToFastq.new/src/c++/lib/demultiplex/BclDemultiplexer.cpp	2013-05-14 15:50:59.987603
447 +0100
@@ -62,7 +62,8 @@
     {
         std::cerr << "Barcode BCLs:\n";
         std::transform(barcodeFiles.begin(), barcodeFiles.end(), std::ostream_iterator<std::string>(std::cerr, "\n"),
-                boost::bind(&fs::path::string, _1));
+		boost::bind(static_cast<std::string const & (fs::path::*)() const>(&fs::path::string), _1));
+	/*boost::bind(&fs::path::string, _1));*/
 
         std::string bases, quality;
         while(clustersToProcess--)
EOF
if [ $? -eq 0 ] ; then
    echo ok
else
    echo ERROR
    echo Patch exited with non-zero status >&2
    exit 1
fi
cd ..
# Make a 'build' dir
BUILD_DIR=build.bcl2fastq-$BCL2FASTQ_VER
create_directory $BUILD_DIR
# Build bcl2fastq
echo Moving to $BUILD_DIR
cd $BUILD_DIR
do_configure --log $LOG_FILE --dir $BCL2FASTQ_DIR/src --prefix=$INSTALL_DIR
do_make --log $LOG_FILE
# Install files
create_directory $INSTALL_DIR
do_make --log $LOG_FILE install
# Finish
cd ..
clean_up_dir $BUILD_DIR
clean_up_dir $BCL2FASTQ_DIR
echo "#%Module1.0"
echo "## bcl2fastq $BCL2FASTQ_VER modulefile"
echo "prepend-path PATH            $INSTALL_DIR/bin"
echo 
