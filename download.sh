#!/bin/bash

## Functions 

download_file () {
    if [ ! -f "$FILE" ]; then
        echo "Downloading $FILE from $URL"
        wget "$URL"
    else
        echo "File already exists: $FILE, not downloading"
    fi
}

## Main Script

# Load config
source ./build-system.conf

# Make download directory
mkdir -p $DLPATH
cd $DLPATH

# Get Caddy web server
URL=$CADDY_URL
FILE=$CADDY_TARBALL
download_file

# Get Homer dashboard
URL=$HOMER_URL
FILE=$HOMER_ZIP
download_file

# Get Authelia
URL=$AUTHELIA_URL
FILE=$AUTHELIA_TARBALL
download_file

# Get code-server
URL=$CS_URL
FILE=$CS_TARBALL
download_file

# Get Jenkins
URL=$JENKINS_URL
FILE=$JENKINS_TARBALL
download_file

# Get JDK17
URL=$JDK17_URL
FILE=$JDK17_TARBALL
download_file

# Get JDK11
URL=$JDK11_URL
FILE=$JDK11_TARBALL
download_file

# Get Rundeck source
URL=$RUNDEK_URL
FILE=$RUNDECK_TARBALL
download_file

cd $CWD