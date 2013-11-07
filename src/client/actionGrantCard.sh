#!/bin/bash

groups=$(request "Groups (separated by comma): ")
password=$(requestPassword "Main password: ")

read -a reply <<< $(IFS=' '; queryDaemon "grant-card $groups $password")

if [[ $reply = "INVALID_PWD" ]]; then
	send "\n\nPassword you've entered is invalid.\nAction canceled.\n"
	pause
elif [[ $reply = "INVALID_GROUP" ]]; then
	send "\n\nGroup(s) you've entered doesn't exists:\n"
	send "\t${reply[1]}\nAction canceled.\n"
	pause
elif [[ $reply = "INSERT_CARD" ]]; then
	send "\n\nPlease swipe your RFID card throught the card reader.\n"
	read -a reply <<< $(IFS=' '; readDaemon)

	if [[ $reply = "READ_TIMEOUT" ]]; then
		send "\n\nYou didn't swipe your card within $cardReadTimeout seconds."
		send "\nAction canceled.\n";
		pause
	else
		send "\n\nGroups has been sucesfully added to the given card.\n"
		pause
	fi
else
	send "\n\nYou entered some information in incorrect format (groups, probably)."
	send "\nAction canceled.\n"
	pause
fi