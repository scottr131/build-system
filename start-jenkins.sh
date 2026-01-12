#!/bin/bash


CWD=$(pwd)
WWWPATH="$CWD/www"
BINPATH="$CWD/bin"
JDKPATH="$CWD/jdk"

mkdir -p $CWD/jenkins

JENKINS_HOME=$CWD/jenkins JAVA_HOME=$JDKPATH/17 $JDKPATH/17/bin/java -jar $BINPATH/jenkins.war --httpPort=8070 >> $CWD/jenkins.log 2>&1 &
