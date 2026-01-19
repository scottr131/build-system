#!/bin/bash


CWD=$(pwd)
LOGPATH="$CWD/logs"
WWWPATH="$CWD/www"
BINPATH="$CWD/bin"
JDKPATH="$CWD/jdk"

mkdir -p $CWD/jenkins
mkdir -p $LOGPATH

JENKINS_HOME=$CWD/jenkins JAVA_HOME=$JDKPATH/17 $JDKPATH/17/bin/java -jar $BINPATH/jenkins.war --httpPort=8070 >> $LOGPATH/jenkins.log 2>&1 &
PID=$!
echo $PID > $LOGPATH/jenkins.pid
