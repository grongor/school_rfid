#!/bin/bash

reply=$(queryDaemon "authenticate" "$(id -nu)")

if [[ $reply = "USER_NOT_FOUND" ]]; then
	send "\n\nYour username '$(id -nu)' isn't assigned to any card."
	pause
elif [[ $reply = "INSERT_CARD" ]]; then
	send "\n\nPlease swipe your RFID card throught the card reader.\n"
	read -a reply <<< $(IFS=' '; readDaemon)
	
	if [[ $reply = "READ_TIMEOUT" ]]; then
		printf "\n\nYou didn't swipe your card within $cardReadTimeout seconds."
		printf "\nAuthentication canceled.\n";
		pause
		continue
	elif [[ $reply = "OK" ]]; then
		sessionKey=${reply[1]}
		printf "\n\nYou were succesfully assigned to these groups: ${reply[2]}\n"
		pause
		break
	elif [[ $reply = "INVALID_CARD" ]]; then
		printf "\n\nThis card is not assigned to you.\nAuthentication canceled.\n"
		pause
		continue
	fi
fi
