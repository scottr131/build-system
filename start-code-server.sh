#!/bin/bash


CWD=$(pwd)
LOGPATH="$CWD/logs"
WWWPATH="$CWD/www"
BINPATH="$CWD/bin"
DLPATH="$CWD/$DLNAME"

mkdir -p $LOGPATH

$BINPATH/code-server/bin/code-server --bind-addr 0.0.0.0:8090 >> $LOGPATH/code-server.log 2>&1 &
PID=$!
echo $PID > $LOGPATH/code-server.pid

# HASHED_PASSWORD='$argon2id$v=19$m=4096,t=3,p=1$VktsZXJnVnJFOEt6bWEzTEZseUhmUT09$qaxfX7udIuRv5qpj1G0AW5DCqpcVG305rbuVthiTkbM' bin/code-server/bin/code-server --bind-addr 0.0.0.0:8090 --auth password

# echo -n "your-password-here" | argon2 "$(openssl rand -base64 16)" -id -e
