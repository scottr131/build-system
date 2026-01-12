#!/bin/bash

DLNAME=downloads

CWD=$(pwd)
DLPATH="$CWD/$DLNAME"

mkdir -p $DLPATH
cd $DLPATH

# Get Caddy web server
wget https://github.com/caddyserver/caddy/releases/download/v2.10.2/caddy_2.10.2_linux_amd64.tar.gz

# Get Homer dashboard
wget https://github.com/bastienwirtz/homer/releases/download/v25.11.1/homer.zip

# Get code-server
wget https://github.com/coder/code-server/releases/download/v4.107.0/code-server-4.107.0-linux-amd64.tar.gz

# Get Jenkins
wget https://get.jenkins.io/war-stable/2.528.3/jenkins.war

# Get JDK17
wget https://github.com/adoptium/temurin17-binaries/releases/download/jdk-17.0.17%2B10/OpenJDK17U-jdk_x64_linux_hotspot_17.0.17_10.tar.gz

# Get JDK11
wget https://github.com/adoptium/temurin11-binaries/releases/download/jdk-11.0.29%2B7/OpenJDK11U-jdk_x64_linux_hotspot_11.0.29_7.tar.gz

# Get Rundeck source
wget https://github.com/rundeck/rundeck/archive/refs/tags/v5.17.0.tar.gz

cd $CWD