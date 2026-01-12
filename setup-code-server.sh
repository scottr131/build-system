#!/bin/bash

DLNAME=downloads

CS_TARBALL="code-server-4.107.0-linux-amd64.tar.gz"

CWD=$(pwd)
BINPATH="$CWD/bin"
DLPATH="$CWD/$DLNAME"

cd $BINPATH
tar xf $DLPATH/$CS_TARBALL
ln -s $(find . -name code-server*) code-server
