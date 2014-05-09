#!/bin/sh
#
# Install Freebayes
#
. $(dirname $0)/import_functions.sh
#
GIT_COMMIT_ID=$1
INSTALL_DIR=$(full_path $2)
if [ -z "$GIT_COMMIT_ID" ] || [ -z "$INSTALL_DIR" ] ; then
  echo Usage: $(basename $0) GIT_COMMIT_ID INSTALL_DIR
  echo Installs freebayes to INSTALL_DIR/freebayes/VERSION/GIT_COMMIT_ID
  exit 1
fi
GIT_REPO=git://github.com/ekg/freebayes.git
BUILD_DIR=freebayes-$GIT_COMMIT_ID-build
LOG_FILE=$(pwd)/install.freebayes.$GIT_COMMIT_ID.log
echo Build freebayes from $GIT_REPO
echo Git commit id $GIT_COMMIT_ID
echo -n Cloning freebayes repo into $BUILD_DIR...
git clone --recursive $GIT_REPO $BUILD_DIR > $LOG_FILE 2>&1
if [ $? -ne 0 ] ; then
  echo ERROR cloning freebayes repo
  exit 1
fi
echo done
cd $BUILD_DIR
echo -n Checking out commit $GIT_COMMIT_ID...
git checkout $GIT_COMMIT_ID >> $LOG_FILE 2>&1
if [ $? -ne 0 ] ; then
  echo ERROR checking out commit
  exit 1
fi
echo done
echo -n Updating submodules...
git submodule update --recursive >> $LOG_FILE 2>&1
if [ $? -ne 0 ] ; then
  echo ERROR updating submodules
  exit 1
fi
echo done
echo -n Running make...
make >> $LOG_FILE 2>&1
if [ $? -ne 0 ] ; then
  echo FAILED
  echo Make returned non-zero exit code
  exit 1
fi
echo done
echo -n Determining full freebayes version...
FULL_FREEBAYES_VERSION=$(bin/freebayes | grep ^version: | cut -c9- | tr -d ' ')
if [ -z "$FULL_FREEBAYES_VERSION" ] ; then
  echo FAILED
  echo Unable to determine version number
  exit 1
fi
echo $FULL_FREEBAYES_VERSION
echo -n Determining base freebayes version...
FREEBAYES_VERSION=$(echo $FULL_FREEBAYES_VERSION | tr -d 'v' | cut -d'-' -f1)
FREEBAYES_VERSION=${FREEBAYES_VERSION%-dirty}
if [ -z "$FREEBAYES_VERSION" ] ; then
  echo FAILED
  echo Unable to determine version number
  exit 1
fi
echo $FREEBAYES_VERSION
INSTALL_DIR=$INSTALL_DIR/freebayes/$FREEBAYES_VERSION/$GIT_COMMIT_ID
echo -n Making installation dir $INSTALL_DIR...
mkdir -p $INSTALL_DIR
echo done
echo -n Copying executables...
cp bin/freebayes bin/bamleftalign $INSTALL_DIR
echo done
cd ..
echo -n Removing $BUILD_DIR...
rm -rf $BUILD_DIR
echo done
exit
##
#