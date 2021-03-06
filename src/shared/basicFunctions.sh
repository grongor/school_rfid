#!/bin/bash

function send() {
	[[ -n "$1" ]] && printf "$@" > /dev/tty
}

function request() {
	local input
	local choices

	send "$1"
	if [[ -z "$2" ]]; then
		read input < /dev/tty
		echo $input
	else
		choices=(${@:2})
		while true; do
			read input < /dev/tty

			inArray $input ${choices[@]}

			if [[ $? -eq 0 ]]; then
				echo $input
				return 0
			else
				send "This option is invalid\n\n$1"
			fi
		done
	fi
}

function requestPassword() {
	local input

	send "$1"
	read -s input < /dev/tty
	echo $input
}

function pause() {
	read -p "Press [Enter] to to continue..." < /dev/tty
}

function inArray() {
	local needle

	for needle in "${@:2}"; do
		[[ $needle = "$1" ]] && return 0
	done
	
	return 1
}
