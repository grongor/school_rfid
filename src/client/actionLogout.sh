#!/bin/bash

username=$(request "\n\nUsername to logout: ")
password=$(requestPassword "Main password: ")

reply=$(queryDaemon "logout $username $password")

if [[ $reply = "INVALID_PWD" ]]; then
	send "\n\nMain password you've entered is invalid.\nAction canceled.\n"
	pause
elif [[ $reply = "USER_NOT_FOUND" ]]; then
	send "\n\nUser '$username' is not logged in.\nAction canceled.\n"
	pause
else
	send "\n\nUser '$username' has been successfully logged out.\n"
	pause
fi