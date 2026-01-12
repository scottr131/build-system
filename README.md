# build-system
Scripts to create a simple web-based software build system.

> [!CAUTION]
> THIS IS A WORK IN PROGRESS
> These scripts will be updated, combined,
> and hopefully refined.  This worked on
> my system, but may not yet work on yours.

These scripts will set up Jenkins, code-server, and Rundeck. In addition it will run an instance of the Homer dashboard on the Caddy web server to make everything easy to access. Future versions may include wssh.

## Setup
Run the scripts in this order. This will eventually be combined into one or two scripts.

`./download.sh`
Downloads the various open source components.

`./setup-jdk.sh`
Unpacks Temurin JDK 11 and 17 to the appropriate directories.

`./build-rundeck.sh`
Unpacks the Rundeck sources and builds `rundeck.war`. This requires JDK 11, so `setup-jdk.sh` MUST be run before this script. 

`./setup-rundeck.sh`
Copies `rundeck.war` will then be copied to the `bin` directory. 

`./setup-jenkins.sh`
Copies `jenkins.war` to the `bin` directory.

`./setup-code-server.sh`
Unpacks code-server into a directory inside `bin`.

`./setup-homer-caddy.sh`
Unpacks the Homer dashboard and Caddy web server.  
