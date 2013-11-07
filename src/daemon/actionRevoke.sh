#!/bin/bash

[[ ${#input[*]} -lt 3 || ${#input[*]} -gt 5 ]] && printf "BAD_REQUEST\n" && continue

########## Check main password
mainPwd=$(cat $passwordStorage)
read -a inputPwd <<< $(IFS=' '; sha512sum <<< ${input[${#input[*]}-1]})

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

########## Username found, check existance of the groups if they are passed in
if [[ ${#input[*]} -eq 5 || ${#input[*]} -eq 4 && ${input[2]} != "allCards" ]]; then
	revokeAllGroups=0
	groups=${input[2]}
	read -a requiredGroups <<< $(IFS=','; echo $groups)
	allGroups=$(cat /etc/group | cut -d: -f1)
	missingGroups=""
	for requiredGroup in ${requiredGroups[*]}; do
		found=0
		while read group; do
			if [[ $group = $requiredGroup ]]; then
				found=1
				break;
			fi
		done <<< "$allGroups"
		if [[ $found -eq 0 ]]; then
			missingGroups="$missingGroups,$requiredGroup"
		fi
	done

	### Group(s) not found
	if [[ -n $missingGroups ]]; then
		printf "INVALID_GROUP ${missingGroups[*]:1}\n"
		continue
	fi
else
	revokeAllGroups=1
fi

########## All groups are ok, read the card or define "allCards"
if [[ ${input[2]} = "allCards" || ${input[3]} = "allCards" ]]; then
	allCards=1
	while IFS=' ' read -r user userCards; do
		if [[ $user = ${input[1]} ]]; then
			read -a userCards <<< $(IFS=','; echo $userCards)
			break
		fi
	done < $usersStorage
else
	allCards=0
	printf "INSERT_CARD\n"

	# cardStatus: 0 => OK, 1 => timeout
	cardStatus=0
	while true; do
		### @todo read the card

		userCards="card1" #ok
		sleep 2
		break

		cardStatus=1 #timeout
	done

	if [ $cardStatus -eq 1 ]; then
		printf "READ_TIMEOUT\n"
		continue
	fi

	########## Card read, check if card belong to give user
	found=0
	while IFS=' ' read -r user cards; do
		if [[ $user = ${input[1]} ]]; then
			read -a cards <<< $(IFS=','; echo $cards)

			for card in ${cards[*]}; do
				if [[ $card = $userCards ]]; then
					found=1
					break
				fi
			done

			break
		fi
	done < $usersStorage

	if [[ $found -eq 0 ]]; then
		printf "INVALID_CARD\n"
		continue
	fi
fi









cards=$(cat $cardsStorage)
#exec 200> $cardsStorage
#flock -x 200

notInCard=""
while IFS=' ' read -r card cardGroups; do
	inArray $card ${userCards[*]}
	if [[ $? -eq 0 ]]; then
		if [[ $revokeAllGroups ]]; then
			continue
		fi
		read -a cardGroups <<< $(IFS=','; echo $cardGroups)

		printf "$card " #>&200

		groupWritten=0
		for r in ${!requiredGroups[*]}; do
			[[ groupWritten -eq 1 ]] && printf "," #>&200
			found=0
			for group in ${cardGroups[*]}; do
				if [[ $group = ${requiredGroups[$r]} ]]; then
					found=1
					break
				fi
			done

			if [[ $found -eq 0 ]]; then
				printf ${requiredGroups[$r]} #>&200
				groupWritten=1
			fi
		done

		for i in ${!cardGroups[*]}; do
			[[ groupWritten -eq 1 || $i -ne 0 ]] && printf "," #>&200
			printf ${cardGroups[$i]} #>&200
		done

		printf "\n" #>&200

		found=1
		continue
	fi

	printf "$card $cardGroups\n" #>&200
done <<< "$cards"

continue

if [[ $found -eq 0 ]]; then
	printf "$readCard ${input[2]}\n" #>&200
fi

#flock -u 200
#exec 200>&-









if [[ $groups = 0 ]]; then
	printf "no groups\n"
else
	printf "$groups\n"
fi

if [[ $allCards -eq 1 ]]; then
	printf "allCards\n"
else
	printf "card $readCard\n"
fi
