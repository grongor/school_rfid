#!/bin/bash

username=$(request "Username: ")
password=$(requestPassword "Main password: ")

read -a reply <<< $(IFS=' '; queryDaemon "grant-user $username $password")

if [[ $reply = "INVALID_PWD" ]]; then
	send "\n\nPassword you've entered is invalid.\nAction canceled.\n"
	pause
elif [[ $reply = "USER_NOT_FOUND" ]]; then
	send "\n\nUsername you've entered doesn't exists.\nAction canceled.\n"
	pause
elif [[ $reply = "INSERT_CARD" ]]; then
	send "\n\nPlease swipe your RFID card throught the card reader.\n"
	read -a reply <<< $(IFS=' '; readDaemon)

	if [[ $reply = "READ_TIMEOUT" ]]; then
		printf "\n\nYou didn't swipe your card within $cardReadTimeout seconds."
		printf "\nAction canceled.\n";
		pause
	else
		send "\n\nUser has been sucesfully assigned to the given card.\n"
		pause
	fi
else
	send "\n\nYou entered some information in incorrect format."
	send "\nAction canceled.\n"
	pause
fi