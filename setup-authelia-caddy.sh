#!/bin/bash

# Load config
source ./build-system.conf
mkdir -p $AUTHPATH

cd $BINPATH
tar xf $DLPATH/$CADDY_TARBALL caddy
tar xf $DLPATH/$AUTHELIA_TARBALL authelia

# Generate random secrets if not specified in configuration file
if [ -z "$JWT_SECRET" ]; then
  echo "Using random JWT secret"
  JWT_SECRET=$($BINPATH/authelia crypto rand --length 64 --charset alphanumeric)
  JWT_SECRET=${JWT_SECRET: -64}
fi

if [ -z "$SESSION_SECRET" ]; then
  echo "Using random session secret"
  SESSION_SECRET=$($BINPATH/authelia crypto rand --length 64 --charset alphanumeric)
  SESSION_SECRET=${SESSION_SECRET: -64}
fi

if [ -z "$STORAGE_SECRET" ]; then
  echo "Using random storage secret"
  STORAGE_SECRET=$($BINPATH/authelia crypto rand --length 64 --charset alphanumeric)
  STORAGE_SECRET=${STORAGE_SECRET: -64}
fi


# Substitute variables into template and save Authelia configuration
JWT_SECRET=$JWT_SECRET \
SESSION_SECRET=$SESSION_SECRET \
STORAGE_SECRET=$STORAGE_SECRET \
BUILD_HOST_FQDN=$BUILD_HOST_FQDN \
envsubst < $TPLPATH/config.yml.template > $AUTHPATH/config.yml

# Substitute variables into template and save Caddy reverse proxy configuration
BUILD_HOST_FQDN=$BUILD_HOST_FQDN \
envsubst < $TPLPATH/Caddyfile.template > $AUTHPATH/Caddyfile


cd $CWD
