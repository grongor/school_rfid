#!/bin/bash

[[ ${#input[*]} -ne 3 && ${#input[*]} -ne 4 ]] && printf "BAD_REQUEST\n" && continue

########## Check main password
mainPwd=$(cat $passwordStorage)
read -a inputPwd <<< $(IFS=' '; sha512sum <<< ${input[2]})

if [[ $mainPwd != $inputPwd ]]; then
	printf "INVALID_PWD\n"
	continue
fi

########## Search for the given username
users=$(cat /etc/passwd | cut -d: -f1)
found=0
while read user; do
	if [[ $user = ${input[1]} ]]; then
		found=1
		break
	fi
done <<< "$users"

### Username not found
if [[ $found -eq 0 ]]; then
	printf "USER_NOT_FOUND\n"
	continue
fi

########## All groups are ok, check for allCards or read the card
if [[ ${#input[*]} -eq 4 && ${input[3]} = "allCards" ]]; then
	allCards=1
else
	allCards=0
	printf "INSERT_CARD\n"

	# cardStatus: 0 => OK, 1 => timeout
	cardStatus=0
	while true; do
		### @todo read the card

		readCard="card1" #ok
		sleep 2
		break

		cardStatus=1 #timeout
	done

	if [ $cardStatus -eq 1 ]; then
		printf "READ_TIMEOUT\n"
		continue
	fi
fi

########## Card read, revoke card(s) from the user
users=$(cat $usersStorage)
exec 200> $usersStorage
flock -x 200

found=0
while IFS=' ' read -r user cards; do
	if [[ $user = ${input[1]} ]]; then
		if [[ $allCards -eq 1 ]]; then
			found=1
			continue
		fi
		read -a cards <<< $(IFS=','; echo $cards)

		cardsToBeWritten=""
		for card in ${cards[*]}; do
			if [[ $card = $readCard ]]; then
				found=1
				continue
			fi
			cardsToBeWritten="$cardsToBeWritten,$card"
		done

		printf "$user ${cardsToBeWritten[*]:1}\n" >&200
		continue
	fi

	printf "$user $cards\n" >&200
done <<< "$users"

if [[ $found -eq 0 ]]; then
	printf "INVALID_CARD\n"
	continue
fi

flock -u 200
exec 200>&-

printf "OK\n"
