#!/bin/bash

username=$(request "Username: ")
do {
	allCards=$(request "Revoke all cards (y/n)?: ")
	if [[ $allCards = "y" ]]; then
		allCards=" allCards"
	elif [[ $allCards = "n" ]]; then
		allCards=""
	else
		continue;
	fi

	break;
} while (true)
password=$(requestPassword "Main password: ")

read -a reply <<< $(IFS=' '; queryDaemon "revoke-user $username $password$allCards")

if [[ $reply = "INVALID_PWD" ]]; then
	send "\n\nPassword you've entered is invalid.\nAction canceled.\n"
	pause
elif [[ $reply = "USER_NOT_FOUND" ]]; then
	send "\n\nUsername you've entered doesn't exists.\nAction canceled.\n"
	pause
elif [[ $reply = "BAD_REQUEST" ]]; then
	send "\n\nYou entered some information in incorrect format."
	send "\nAction canceled.\n"
	pause
else
	if [[ $reply = "INSERT_CARD" ]]; then
		send "\n\nPlease swipe your RFID card throught the card reader.\n"
		read -a reply <<< $(IFS=' '; readDaemon)

		if [[ $reply = "READ_TIMEOUT" ]]; then
			printf "\n\nYou didn't swipe your card within $cardReadTimeout seconds."
			printf "\nAction canceled.\n";
			pause
			continue
		fi
	fi
	send "\n\nUser has been sucesfully revoked from the given card.\n"
	pause
fi