#!/bin/bash

path=/dev/tcp/$hostname/$port

exec 3<> $path

trap "exec 3>&- ; exec 3<&-" EXIT

function queryDaemon() {
	[[ -z "$1" ]] && exit 1
	
	echo "$@" >&3

	readDaemon
}

function readDaemon() {
	read line <&3
	echo $line
}

read -a reply <<< $(IFS=','; queryDaemon HELLO)

if [[ ${#reply[*]} -ne 5 ]]; then
	error="Daemon's welcome message was invalid - application cannot continue"
	kill $$
fi