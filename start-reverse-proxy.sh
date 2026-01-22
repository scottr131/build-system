#!/bin/bash

# Load config
source ./build-system.conf

CWD=$(pwd)

cd $AUTHPATH

# Start an instance of Caddy on port 8000 serving Homer dashboard from www directory
sudo --preserve-env=LOGPATH $BINPATH/caddy run >> $LOGPATH/caddy-rp.log 2>&1 &
PID=$!
echo $PID > $LOGPATH/caddy-rp.pid