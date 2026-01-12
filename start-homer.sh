#!/bin/bash


CWD=$(pwd)
WWWPATH="$CWD/www"
BINPATH="$CWD/bin"
DLPATH="$CWD/$DLNAME"

# Start an instance of Caddy on port 8000 serving Homer dashboard from www directory
$BINPATH/caddy file-server --listen :8000 --root www/ >> $CWD/caddy.log 2>&1 &