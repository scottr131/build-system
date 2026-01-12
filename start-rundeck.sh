#!/bin/bash


CWD=$(pwd)
WWWPATH="$CWD/www"
BINPATH="$CWD/bin"
JDKPATH="$CWD/jdk"
RDECK_BASE="$CWD/rundeck"

if [ ! -d "$RDECK_BASE" ]; then
    mkdir -p $RDECK_BASE
    echo "Created RDECK_BASE - $RDECK_BASE" >> $CWD/rundeck.log
fi

if [ ! -f "$RDECK_BASE/rundeck.war" ]; then
    cp $BINPATH/rundeck.war $RDECK_BASE/rundeck.war
    echo "Copied rundeck.war from $BINPATH" >> $CWD/rundeck.log
fi


PATH=$PATH:$RDECK_BASE/tools/bin MANPATH=$MANPATH:$RDECK_BASE/docs/man JAVA_HOME=$JDKPATH/java17 $JDKPATH/17/bin/java -Xmx4g -jar $RDECK_BASE/rundeck.war >> $CWD/rundeck.log 2>&1 &
