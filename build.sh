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

message "Building the R.Neo4j-Browser and creating a JAR file."

message "Installing Node Modules"

npm install

message "Installing Bower components"

bower install

message "Building Neo4j Browser"

grunt build

message "Assembling JAR file"

mvn package
