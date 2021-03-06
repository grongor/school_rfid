#!/bin/bash

trap handleSIGTERM SIGTERM

function handleSIGTERM() {
	if [[ -n "$error" ]]; then
		send "\n\t$error\n\n"
	else
		send "\n\tThere was an unexpected error - application cannot continue\n\n"
	fi

	exit 0
}