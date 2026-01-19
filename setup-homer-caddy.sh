#!/bin/bash

DLNAME=downloads
WWWNAME=www

CADDY_TARBALL=caddy_2.10.2_linux_amd64.tar.gz

CWD=$(pwd)
JDKPATH="$CWD/jdk"
DLPATH="$CWD/$DLNAME"
BLDPATH="$CWD/build"
BINPATH="$CWD/bin"
WWWPATH="$CWD/$WWWNAME"

mkdir -p $WWWPATH

cd $WWWPATH
unzip $DLPATH/homer.zip

cd $BINPATH
tar xf $DLPATH/$CADDY_TARBALL caddy


# cp $DLPATH/jenkins.war $BINPATH/jenkins.war
