#!/bin/bash

# Load config
source ./build-system.conf

# Load previous secrets if available
# Secrets file values override conf file
if [ -f ".secrets" ]; then
  echo "Using existing secrets"
  source ./.secrets
else
  echo "Missing secrets will be generated"
fi


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

# Gather username and password if needed
if [ -z "$AUTH_USER" ]; then
  echo "No user specified in configuration or secrets file"
  read -p "Enter desired username for reverse proxy: " AUTH_USER
  echo "Using $AUTH_USER as username"
fi

if [ -z "$PASS_HASH" ]; then
  # No password hash was specified
  if [ -z "$USER_PASSWORD"]; then
    # A password was also not specified, so prompt
    echo "No password hash or password specified in configuration or secrets file, prompting for password"
    read -s -p "Password: " USER_PASSWORD
    echo
    read -s -p "Confirm: " USER_CONFIRM
    echo
    if [ "$USER_PASSWORD" != "$USER_CONFIRM" ]; then
      # Exit for now, this could re-prompt
      unset USER_PASSWORD
      unset USER_CONFIRM
      echo "Passwords don't match.  Exiting.'"
      exit 1
    fi
    unset USER_CONFIRM
  fi
      
  PASS_HASH=$($BINPATH/authelia crypto hash generate argon2 --password $USER_PASSWORD)
  unset USER_PASSWORD
  PASS_HASH="${PASS_HASH:8}"
fi

# PASS_HASH should exist now (by secrets, conf, or prompt)
#echo "Authelia user: $AUTH_USER"
#echo "Password hash: $PASS_HASH"
#exit 1

# Substitute variables into template and save Authelia configuration
JWT_SECRET=$JWT_SECRET \
SESSION_SECRET=$SESSION_SECRET \
STORAGE_SECRET=$STORAGE_SECRET \
BUILD_HOST_FQDN=$BUILD_HOST_FQDN \
envsubst < $TPLPATH/config.yml.template > $AUTHPATH/config.yml

# Substitute variables into template and save Caddy reverse proxy configuration
BUILD_HOST_FQDN=$BUILD_HOST_FQDN \
envsubst < $TPLPATH/Caddyfile.template > $AUTHPATH/Caddyfile

# Substitute variables into user list and save configuration
AUTH_USER=$AUTH_USER \
PASS_HASH=$PASS_HASH \
envsubst < $TPLPATH/users_database.yml.template > $AUTHPATH/users_database.yml

cd $CWD

# Save to secrets file so secrets can be re-used on next run
echo "JWT_SECRET=$JWT_SECRET" > .secrets
echo "SESSION_SECRET=$SESSION_SECRET" >> .secrets
echo "STORAGE_SECRET=$STORAGE_SECRET" >> .secrets
echo "AUTH_USER=$AUTH_USER" >> .secrets
echo "PASS_HASH=$PASS_HASH" >> .secrets
