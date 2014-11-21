#!/bin/sh
#
# Install ceasBW package from the cistrome bitbucket repository
#
. $(dirname $0)/import_functions.sh
#
function install_dependency() {
    # Function wrapping installation of Python libraries
    # that ceasBW needs to run
    # 1: URL to get the source code from
    # 2: full path to python executable to use for installation
    # 3: installation dir
    local dependency=$(basename $1)
    local python=$2
    local install_dir=$3
    echo Install dependency $dependency
    wget_url $1
    unpack_archive $dependency
    install_python_package $python $dependency $install_dir
    clean_up $dependency
    clean_up_file $dependency
}
PYTHON=$1
COMMIT_ID=$2
INSTALL_DIR=$(full_path $3)
if [ -z "$PYTHON" ] || [ -z "$COMMIT_ID" ] || [ -z "$INSTALL_DIR" ] ; then
  echo Usage: $(basename $0) PYTHON COMMIT_ID INSTALL_DIR
  echo Installs ceasBW package from cistrome into INSTALL_DIR/ceasbw/COMMIT_ID
  echo 
  echo NB ceasBW is an alternative version of the CEAS package
  echo which can handle bigWig files. It is NOT versioned officially
  echo so commit IDs are used instead.
  exit 1
fi
echo Installing ceasBW commit id $COMMIT_ID
echo Using Python from $(dirname $PYTHON)
# Clone the cistrome source code
hg_clone --no-log https://bitbucket.org/cistrome/cistrome-applications-harvard
cd cistrome-applications-harvard
run_command "Switching to commit id $COMMIT_ID" hg update -r $COMMIT_ID
cd ..
# Installation directory
INSTALL_DIR=$INSTALL_DIR/ceasbw/$COMMIT_ID
echo Installing under $INSTALL_DIR
create_directory $INSTALL_DIR
# Handle dependencies
prepend_path PYTHONPATH $INSTALL_DIR/lib64/python2.7/site-packages
prepend_path PYTHONPATH $INSTALL_DIR/lib/python2.7/site-packages
install_dependency \
    https://pypi.python.org/packages/source/n/numpy/numpy-1.7.1.tar.gz \
    $PYTHON $INSTALL_DIR
install_dependency \
    https://pypi.python.org/packages/source/b/bx-python/bx-python-0.7.1.tar.gz \
    $PYTHON $INSTALL_DIR
install_dependency \
    https://pypi.python.org/packages/source/M/MySQL-python/MySQL-python-1.2.5.zip \
    $PYTHON $INSTALL_DIR
# Install ceasBW
cd cistrome-applications-harvard/published-packages/CEAS
$PYTHON setup.py install --prefix=$INSTALL_DIR
# Finish up
cd ../../..
clean_up_dir cistrome-applications-harvard
echo "#%Module1.0"
echo "## ceasbw $COMMIT_ID modulefile"
echo "prepend-path PATH            $INSTALL_DIR/bin"
echo "prepend-path PYTHONPATH      $INSTALL_DIR/lib64/python2.7/site-packages"
echo "prepend-path PYTHONPATH      $INSTALL_DIR/lib/python2.7/site-packages"
echo 
##
#
