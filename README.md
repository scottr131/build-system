# build-system

Scripts to create a simple web-based software build system.

> [!CAUTION]
> THIS IS A WORK IN PROGRESS
> These scripts will be updated, combined,
> and hopefully refined.  This worked on
> my system, but may not yet work on yours.

These scripts will set up Jenkins, code-server, and Rundeck. In addition it will run an instance of the Homer dashboard on the Caddy web server to make everything easy to access. Future versions may include wssh.

## Setup

### Configure user

Most of the build system components can run as a regular user.  This user does need `sudo` access, as the Caddy reverse proxy process needs to bind to ports 80 and 443.

### Configure build-system

Edit `build-system.conf` to customize the configuration.  If you do not edit the file, the secrets for Authelia will be randomly generated, and you will be prompted for an Authelia username and password.

URLs for the various open-source components can also be updated in this file.

### Set up components

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

`./setup-authelia-caddy.sh`
Unpacks Authelia and configures an authenticaed reverse proxy using Caddy and Authelia.  This script will prompt for an Authelia username and password if they are not specified in `build-system.conf`.

## Starting

There isn't really a particular order these scripts need to be run in, but this order is suggested.  These will eventually be combined into a single startup script.

`./start-code-server.sh`
Starts code-server.

`./start-jenkins.sh`
Starts Jenkins.

`./start-rundeck.sh`
Starts Rundeck.

`./start-homer.sh`
Starts a copy of Caddy serving the Homer dashboard.

`./start-reverse-proxy.sh`
Starts a copy of Caddy and Authelia working as a reverse proxy with authentication for the above services.

## Ports

Services will be started on the following ports.

| Service       | Port    |
|:------------- |:------- |
| Reverse proxy | 80, 443 |
| Code-server   | 8090    |
| Jenkins       | 8070    |
| Rundeck       | 4440    |
