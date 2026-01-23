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
            'dirs'|'directories')
                echo "Setup directories"
                setup_directories
                ;;
            *)
                echo "$2 is not a valid option for 'setup'"
                ;;
        esac
        ;;
    start)
        case "$2" in
            jenkins)
                echo "Start Jenkins"
                ;;
            *)
                echo "$2 is not a valid option for 'start'"
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