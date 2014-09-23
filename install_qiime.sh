#!/bin/sh
#
# Install qiime
# See http://qiime.org/install/install.html
#
. $(dirname $0)/import_functions.sh
#
PYTHON=$(full_path $1)
TARGZ=$2
INSTALL_DIR=$3
if [ -z "$PYTHON" ] || [ -z "$TARGZ" ] || [ -z "$INSTALL_DIR" ] ; then
  echo Usage: $(basename $0) PYTHON TARGZ INSTALL_DIR
  echo Installs qiime into INSTALL_DIR/qiime/VERSION
  exit 1
fi
QIIME_DIR=$(package_dir $TARGZ)
QIIME_VER=$(package_version $TARGZ)
INSTALL_DIR=$(full_path $INSTALL_DIR)/qiime/$QIIME_VER
echo Install qiime from $TARGZ
echo Version $QIIME_VER
# Check the Python version
echo -n Checking Python version...
PYTHON_VERSION=$($PYTHON --version 2>&1 | cut -d" " -f2)
if [ $PYTHON_VERSION != "2.7.3" ] ; then
    echo $PYTHON_VERSION
    echo ERROR qiime needs Python 2.7.3 2>&1
    exit 1
fi
echo $PYTHON_VERSION \(ok\)
# Set up build log
LOG_FILE=$(pwd)/install.qiime.$QIIME_VER.log
clean_up_file $LOG_FILE
# Handle dependencies
echo Handling qiime Python dependencies
prepend_path PYTHONPATH $(python_lib_dir $PYTHON $INSTALL_DIR)
QIIME_DEPENDENCIES=\
"numpy|1.7.1|http://sourceforge.net/projects/numpy/files/NumPy/1.7.1/numpy-1.7.1.tar.gz \
matplotlib|1.3.1|https://downloads.sourceforge.net/project/matplotlib/matplotlib/matplotlib-1.3.1/matplotlib-1.3.1.tar.gz \
cogent|1.5.3|https://pypi.python.org/packages/source/c/cogent/cogent-1.5.3.tgz \
pyqi|0.3.2|https://pypi.python.org/packages/source/p/pyqi/pyqi-0.3.2.tar.gz \
biom|1.3.1|https://pypi.python.org/packages/source/b/biom-format/biom-format-1.3.1.tar.gz \
qcli|0.1.0|https://pypi.python.org/packages/source/q/qcli/qcli-0.1.0.tar.gz \
pynast|1.2.2|https://pypi.python.org/packages/source/p/pynast/pynast-1.2.2.tar.gz \
emperor|0.9.3|https://pypi.python.org/packages/source/e/emperor/emperor-0.9.3.tar.gz \
sphinx|1.2.3|https://pypi.python.org/packages/source/S/Sphinx/Sphinx-1.2.3.tar.gz"
for dep in $QIIME_DEPENDENCIES ; do
    # Get details of dependency
    PACKAGE=$(basename $dep)
    PACKAGE_NAME=$(echo $dep | cut -d'|' -f1)
    PACKAGE_VER=$(echo $dep | cut -d'|' -f2)
    URL=$(echo $dep | cut -d'|' -f3-)
    echo "#### $PACKAGE_NAME $PACKAGE_VER ####"
    # Check if we need to install this dependency
    echo -n Checking for $PACKAGE_NAME...
    got_package=$(python_package_installed $PYTHON $PACKAGE_NAME)
    if [ ! -z "$got_package" ] ; then
	echo -n $got_package
	if [ "$got_package" == "$PACKAGE_VER" ] ; then
	    echo , ok
	else
	    echo , need $PACKAGE_VER
	    got_package=
	fi
    else
	echo not found
    fi
    # Download and install dependency if required
    if [ -z "$got_package" ] ; then
	wget_url $dep
	if [ $? -ne 0 ] ; then
	    echo ERROR
	    echo Failed to download $PACKAGE >&2
	    exit 1
	fi
	unpack_archive $PACKAGE
	install_python_package $PYTHON $PACKAGE $INSTALL_DIR
	clean_up $PACKAGE
    fi
done
# Install Qiime as a Python application
echo "#### qiime $QIIME_VER ####"
unpack_archive $TARGZ
install_python_package $PYTHON $TARGZ $INSTALL_DIR
# Finish up
clean_up $TARGZ
# Check install
prepend_path PATH $INSTALL_DIR/bin
prepend_path PATH $(dirname $PYTHON)
prepend_path PYTHONPATH $(python_lib_dir $PYTHON $INSTALL_DIR)
print_qiime_config.py -t
# Report example environment module settings
echo "#%Module1.0"
echo "## qiime $QIIME_VER modulefile"
echo "prepend-path PATH            $(dirname $PYTHON)"
echo "prepend-path PATH            $INSTALL_DIR/bin"
echo "prepend-path PYTHONPATH      $(python_lib_dir $PYTHON $INSTALL_DIR)"
echo 
echo See http://qiime.org/install/install.html for installation of
echo additional dependencies e.g. usearch, uclust etc
##
#
