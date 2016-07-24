#!/bin/bash

function line() {
	printf '%*s' $2 | tr ' ' "$1"
	printf "\n"
}

function message() {
	local SIZE=$((${#1} + 2))
	echo
	line "=" $SIZE
	echo " $1"
	line "=" $SIZE
	echo
}

function error() {
	echo "Aborted. $1"
	exit 1
}

function is_exists() {
	local FILE=$(command -v $1)
	[ ! -z "$FILE" ] && [ -e "$FILE" ] && return 0 || return 1
}



message "Neo4j-Browser With Custom UI Prerequisition Script (Ubuntu 14.04 x86_64)"

if [ $(whoami) != "root" ]; then
	error "This script requires root privileges."
fi

ARCH=$(uname -m)

if [ -f /etc/lsb-release ]; then
    OS=$(lsb_release -si)
    VER=$(lsb_release -sr)
elif [ -f /etc/debian_version ]; then
    OS=Debian  # XXX or Ubuntu??
    VER=$(cat /etc/debian_version)
else
    OS=$(uname -s)
    VER=$(uname -r)
fi

if [ $OS != "Ubuntu" ] || [ $ARCH != "x86_64" ] || [ $VER != "14.04" ]; then
	read -p "This script requires Ubuntu 14.04 (x86_64), and your system is $OS $VER ($ARCH). Should we continue? [y/N]?" -r RESP
else
	read -p "This script will install packages, required for compiling Neo4j-Browser. Continue [y/N]?" -r RESP
fi

if [[ ! $RESP =~ ^[Yy]$ ]]; then
	error
fi

if ( is_exists "node" ); then 
	NODE=$(node --version)
	if [ -z $NODE ]; then 
		read -p "The script has detected incorrect Node.JS version installed on this machine. To continue, this Node.JS version shoud be removed. Continue? [y/N]?" -r RESP

		if [[ ! $RESP =~ ^[Yy]$ ]]; then
		        error
		fi

		apt-get --purge -y remove node nodejs nodejs-legacy

		if [ -e /usr/bin/node ]; then
		        rm /usr/bin/node
		fi

		hash -d node
	fi
fi

if ( ! is_exists "git"); then 
	message "Installing Git"

	apt-get install -y git
fi

GIT=$(git --version | awk '{print $3}')
if [ -z "$GIT" ]; then
	error "Error in Git installation"
else
	message "Git Version: $GIT"
fi

if ( ! is_exists "java" ); then #
	message "Installing JDK"

	apt-get install -y openjdk-7-jdk
fi

JAVA=$(java -version 2>&1 | awk -F '"' '/version/ {print $2}')
if [ -z "$JAVA" ]; then
	error "Error in JDK installation"
else
	message "JDK Version: $JAVA"
fi

if ( ! is_exists "mvn" ); then #
	message "Installing Maven"

	apt-get install -y maven
fi

MAVEN=$(mvn -version | awk '/Apache Maven/ {print $3}')
if [ -z "$MAVEN" ];  then
	error "Error in Maven installation"
else
	message "Maven Version: $MAVEN"
fi

if ( ! is_exists "node" ); then #
	message "Installing Node.JS"

	apt-get install -y nodejs nodejs-legacy
fi

NODE=$(node --version)
if [ -z "$NODE" ]; then
	error "Error in Node installation"
else
	message "Node Version: $NODE"
fi

if ( ! is_exists "npm" ); then #
	message "Installing NPM"

	apt-get install -y npm
fi

NPM=$(npm -version)
if [ -z "$NPM" ]; then
	error "Error in NPM installation"
else
	message "NPM Version: $NPM"
fi

message "Updating Node.JS modules"

npm install -g npm 
npm install -g grunt-cli
npm install -g bower

message "SUCCESS"
