#!/bin/bash

DLNAME=downloads
RDECK_SRC_TARBALL="v5.17.0.tar.gz"


CWD=$(pwd)
JDKPATH="$CWD/jdk"
DLPATH="$CWD/$DLNAME"
BLDPATH="$CWD/build"

mkdir -p $BLDPATH

cd $BLDPATH
tar xf $DLPATH/$RDECK_SRC_TARBALL

ln -s $(find . -name rundeck-*) rundeck
cd rundeck

git init
git add .
git config user.email "builder"
git config user.name "builder"
git commit -m "fake"
JAVA_HOME=/home/clusteradm/build-system/jdk/11 PATH=$PATH:/home/clusteradm/build-system/jdk/11/bin ./gradlew -x check build