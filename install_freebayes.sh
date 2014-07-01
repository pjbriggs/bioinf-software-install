#!/bin/sh
#
# Install Freebayes
#
# Tested with versions:
#
# - 0.9.6  (commit id: 9608597d12e127c847ae03aa03440ab63992fedf)
# - 0.9.13 (commit id: c807ef8339b3c6bb99fa8083f7689933971257b6)
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
do_make --log $LOG_FILE
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
create_directory $INSTALL_DIR
echo Installing executables
copy_files bin/freebayes bin/bamleftalign $INSTALL_DIR
cd ..
clean_up_dir $BUILD_DIR
exit
##
#
