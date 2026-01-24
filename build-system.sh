#!/bin/bash


CONF_FILE=build-system.conf

# You shouldn't need to edit below this line

CWD=$(pwd)

# Load the config file or error out
if [ -r $CONF_FILE ]; then
    source $CONF_FILE
else
    echo "Configuration file $CONF_FILE was not found and must be present."
    exit 1
fi

### Functions
## Build functions
build_rundeck() {
    cd $BLDPATH
    tar xf $DLPATH/$RDECK_SRC_TARBALL

    ln -s $(find . -name rundeck-*) rundeck
    cd rundeck

    git init
    git add .
    git config user.email "builder"
    git config user.name "builder"
    git commit -m "fake"
    JAVA_HOME=/home/clusteradm/build-system/jdk/11 PATH=$PATH:/home/clusteradm/build-system/jdk/11/bin ./gradlew -x check build
}

## Download functions
download_authelia() {
    URL=$AUTHELIA_URL
    FILE=$AUTHELIA_TARBALL
    download_file
}
download_caddy() {
    URL=$CADDY_URL
    FILE=$CADDY_TARBALL
    download_file
}
download_code-server() {
    URL=$CS_URL
    FILE=$CS_TARBALL
    download_file
}
download_homer() {
    URL=$HOMER_URL
    FILE=$HOMER_ZIP
    download_file
}
download_jdk11() {
    URL=$JDK11_URL
    FILE=$JDK11_TARBALL
    download_file
}
download_jdk17() {
    URL=$JDK17_URL
    FILE=$JDK17_TARBALL
    download_file
}
download_jenkins() {
    URL=$JENKINS_URL
    FILE=$JENKINS_TARBALL
    download_file
}
download_rundeck() {
    URL=$RUNDECK_URL
    FILE=$RUNDECK_TARBALL
    download_file
}


## Setup functions
# Setup working directories
setup_directories() {
    mkdir -p $AUTHPATH
    mkdir -p $BINPATH
    mkdir -p $BLDPATH
    mkdir -p $DLPATH
    mkdir -p $JDKPATH
    mkdir -p $LOGPATH
    mkdir -p $WWWPATH
}

setup_code_server() {
    cd $BINPATH
    tar xf $DLPATH/$CS_TARBALL
    ln -s $(find . -name code-server*) code-server   

    cd $CWD 
}

setup_homer() {
    cd $WWWPATH
    unzip $DLPATH/homer.zip

    cd $BINPATH
    tar xf $DLPATH/$CADDY_TARBALL caddy

    cd $CWD
}

setup_jdk() {
    cd $JDKPATH
    tar xf $DLPATH/$JDK11_TARBALL
    tar xf $DLPATH/$JDK17_TARBALL
    ln -s $(find . -name jdk-11*) 11
    ln -s $(find . -name jdk-17*) 17    
}

setup_jenkins()
{
    cp $DLPATH/jenkins.war $BINPATH/jenkins.war
}

setup_reverse_proxy() {
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
}

setup_rundeck()
{
    if [ ! -f "$BLDPATH/rundeck-$RDECK_VERSION/rundeckapp/build/libs/rundeck-$RDECK_VERSION-SNAPSHOT.war" ]; then
        echo "Rundeck WAR file not found in build directory.  Did you run \"$0 build rundeck\" first?"
        exit 1
    else
        echo "Setup Rundeck"        
        cp $BLDPATH/rundeck-$RDECK_VERSION/rundeckapp/build/libs/rundeck-$RDECK_VERSION-SNAPSHOT.war $BINPATH/rundeck.war
    fi
}

## Startup functions
start_code_server() {
    $BINPATH/code-server/bin/code-server --bind-addr 0.0.0.0:8090 >> $LOGPATH/code-server.log 2>&1 &
    PID=$!
    echo $PID > $LOGPATH/code-server.pid
}

start_homer() {
    # Start an instance of Caddy on port 8000 serving Homer dashboard from www directory
    $BINPATH/caddy file-server --listen :8000 --root www/ >> $CWD/caddy.log 2>&1 &
}

start_jenkins() {
    JENKINS_HOME=$CWD/jenkins JAVA_HOME=$JDKPATH/17 $JDKPATH/17/bin/java -jar $BINPATH/jenkins.war --httpPort=8070 >> $LOGPATH/jenkins.log 2>&1 &
    PID=$!
    echo $PID > $LOGPATH/jenkins.pid    
}

start_reverse_proxy() {
    cd $AUTHPATH

    # Start Authelia
    $BINPATH/authelia --config config.yml >> $LOGPATH/authelia.log 2>&1 &
    PID=$!
    echo $PID > $LOGPATH/authelia.pid

    # Start an instance of Caddy on port 8000 serving Homer dashboard from www directory
    sudo --preserve-env=LOGPATH $BINPATH/caddy run >> $LOGPATH/caddy-rp.log 2>&1 &
    PID=$!
    echo $PID > $LOGPATH/caddy-rp.pid

    cd $CWD    
}

start_rundeck() {
    if [ ! -d "$RDECK_BASE" ]; then
        mkdir -p $RDECK_BASE
        echo "Created RDECK_BASE - $RDECK_BASE" >> $CWD/rundeck.log
    fi

    if [ ! -f "$RDECK_BASE/rundeck.war" ]; then
        cp $BINPATH/rundeck.war $RDECK_BASE/rundeck.war
        echo "Copied rundeck.war from $BINPATH" >> $CWD/rundeck.log
    fi


    PATH=$PATH:$RDECK_BASE/tools/bin MANPATH=$MANPATH:$RDECK_BASE/docs/man JAVA_HOME=$JDKPATH/java17 $JDKPATH/17/bin/java -Xmx4g -jar $RDECK_BASE/rundeck.war >> $CWD/rundeck.log 2>&1 &
}

## Stop functions
stop_jenkins() {
    if [ -r "$LOGPATH/jenkins.pid" ]; then
        echo "Stopping Jenkins"
        kill $(cat $LOGPATH/jenkins.pid)
        rm $LOGPATH/jenkins.pid
    else
        echo "No PID file found!  Could not stop Jenkins."
    fi
}

## Helper functions
download_file () {
    if [ ! -f "$FILE" ]; then
        echo "Downloading $FILE from $URL"
        wget "$URL"
    else
        echo "File already exists: $FILE, not downloading"
    fi
}





### Main switch
case "$1" in
    build)
        case "$2" in
            rundeck)
                echo "Build Rundeck"
                build_rundeck
                ;;
            *)
                echo "$2 is not a valid option for 'build'"
                ;;
        esac
        ;;

    'download')
        # Make download directory
        mkdir -p $DLPATH
        cd $DLPATH

        # Download specified program
        case "$2" in
            authelia)
                download_authelia
                ;;
            caddy)
                download_caddy
                ;;
            code-server)
                download_code-server
                ;;
            homer)
                download_homer
                ;;
            jdk11)
                download_jdk11
                ;;
            jdk17)
                download_jdk17
                ;;
            jenkins)
                download_jenkins
                ;;
            rundeck)
                download_rundeck
                ;;
            *)
                echo "$2 is not a valid option for 'start'"
                cd $CWD
                ;;
        esac
        cd $CWD
        ;;
    setup)
        case "$2" in
            'cs'|'code-server')
                echo "Setup code-server"
                setup_code_server
                ;;
            'dirs'|'directories')
                echo "Setup directories"
                setup_directories
                ;;
            'homer')
                echo "Setup Homer dashboard"
                setup_homer
                ;;
            'jdk')
                echo "Setup JDKs"
                setup_jdk
                ;;
            'jenkins')
                echo "Setup Jenkins"
                setup_jenkins
                ;;
            'rp'|'reverse-proxy')
                echo "Setup reverse proxy with Authelia and Caddy"
                setup_reverse_proxy
                ;;
            'rundeck')
                echo "Setup Rundeck"
                setup_rundeck
                ;;
            *)
                echo "$2 is not a valid option for 'setup'"
                ;;
        esac
        ;;
    start)
        case "$2" in
            code-server)
                echo "Start code-server"
                start_code_server
                ;;
            homer)
                echo "Start Homer with Caddy"
                start_homer
                ;;
            jenkins)
                echo "Start Jenkins"
                start_jenkins
                ;;
            'rp'|'reverse-proxy')
                echo "Start reverse proxy"
                start_reverse_proxy
                ;;
            rundeck)
                echo "Start Rundeck"
                start_rundeck
                ;;
            *)
                echo "$2 is not a valid option for 'start'"
                ;;
        esac
        ;;
    stop)
        case "$2" in
            jenkins)
                stop_jenkins
                ;;
            *)
                echo "You must specify a valid process to stop."
                ;;
        esac
        ;;
    *)
        if [ -n "$1" ]; then
            echo "$1 is not a valid command"
            echo ""
        fi
        echo "$0 <action> [object]"
        exit 1
        ;;
esac

cd $CWD            