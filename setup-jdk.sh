#!/bin/bash

DLNAME=downloads

JDK11_TARBALL="OpenJDK11U-jdk_x64_linux_hotspot_11.0.29_7.tar.gz"
JDK17_TARBALL="OpenJDK17U-jdk_x64_linux_hotspot_17.0.17_10.tar.gz"


CWD=$(pwd)
JDKPATH="$CWD/jdk"
DLPATH="$CWD/$DLNAME"

mkdir -p $JDKPATH

cd $JDKPATH
tar xf $DLPATH/$JDK11_TARBALL
tar xf $DLPATH/$JDK17_TARBALL
ln -s $(find . -name jdk-11*) 11
ln -s $(find . -name jdk-17*) 17
