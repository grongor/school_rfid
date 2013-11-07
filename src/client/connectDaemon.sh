#!/bin/bash

path=/dev/tcp/$hostname/$port

error=$( (exec 3<> $path) 2>&1 )

if [[ -n $error ]]; then
	error="Cannot connect to daemon. Please check if daemon is running."
	kill $$
fi

exec 3<> $path

trap "exec 3>&- ; exec 3<&-" EXIT

function queryDaemon() {
	[[ -z "$1" ]] && exit 1
	
	echo "$@" >&3 2> /dev/null

	readDaemon
}

function readDaemon() {
	read line <&3 2> /dev/null
	echo $line
}

read -a reply <<< $(IFS=','; queryDaemon HELLO)

if [[ ${#reply[*]} -ne 7 ]]; then
	error="Daemon's welcome message was invalid - application cannot continue"
	kill $$
fi