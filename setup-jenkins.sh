#!/bin/bash

DLNAME=downloads


CWD=$(pwd)
JDKPATH="$CWD/jdk"
DLPATH="$CWD/$DLNAME"
BLDPATH="$CWD/build"
BINPATH="$CWD/bin"

cp $DLPATH/jenkins.war $BINPATH/jenkins.war
