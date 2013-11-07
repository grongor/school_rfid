#!/bin/bash

[[ ${#input[*]} -ne 3 ]] && printf "BAD_REQUEST\n" && continue

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

########## All groups are ok, read the card
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

########## Card read, add card to the user
users=$(cat $usersStorage)
exec 200> $usersStorage
flock -x 200

found=0
while IFS=' ' read -r user cards; do
	if [[ $user = ${input[1]} ]]; then
		read -a cards <<< $(IFS=','; echo $cards)

		groupsToBeWritten=""
		for card in ${cards[*]}; do
			[[ $card = $readCard ]] && found=1
			groupsToBeWritten="$groupsToBeWritten,$card"
		done

		[[ $found -eq 0 ]] && groupsToBeWritten="$groupsToBeWritten,$readCard"
		printf "$user $groupsToBeWritten\n" >&200

		found=1
		continue
	fi

	printf "$user $cards\n" >&200
done <<< "$users"

if [[ $found -eq 0 ]]; then
	printf "${input[1]} $readCard\n" >&200
fi

flock -u 200
exec 200>&-

printf "OK\n"
