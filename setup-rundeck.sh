#!/bin/bash

DLNAME=downloads
RDECK_VERSION="5.17.0"


CWD=$(pwd)
JDKPATH="$CWD/jdk"
DLPATH="$CWD/$DLNAME"
BLDPATH="$CWD/build"
BINPATH="$CWD/bin"

cp $BLDPATH/rundeck-$RDECK_VERSION/rundeckapp/build/libs/rundeck-$RDECK_VERSION-SNAPSHOT.war $BINPATH/rundeck.war
