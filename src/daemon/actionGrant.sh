#!/bin/bash

[[ ${#input[*]} -ne 4 ]] && printf "BAD_REQUEST\n" && continue

########## Check main password
mainPwd=$(cat $passwordStorage)
read -a inputPwd <<< $(IFS=' '; sha512sum <<< ${input[3]})

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

########## Username found, check existance of the groups
read -a requiredGroups <<< $(IFS=','; echo ${input[2]})
groups=$(cat /etc/group | cut -d: -f1)
missingGroups=""
for requiredGroup in ${requiredGroups[*]}; do
	found=0
	while read group; do
		if [[ $group = $requiredGroup ]]; then
			found=1
			break;
		fi
	done <<< "$groups"
	if [[ $found -eq 0 ]]; then
		missingGroups="$missingGroups,$requiredGroup"
	fi
done

### Group(s) not found
if [[ -n $missingGroups ]]; then
	printf "INVALID_GROUP ${missingGroups[*]:1}\n"
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

		printf "$user " >&200
		for i in ${!cards[*]}; do
			[[ $i -ne 0 ]] && printf "," >&200
			[[ ${cards[$i]} = $readCard ]] && found=1
			printf ${cards[$i]} >&200
		done

		[[ $found -eq 0 ]] && printf ",$readCard" >&200
		printf "\n" >&200

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

########## Card added to the user, add group(s) to the card
cards=$(cat $cardsStorage)
exec 200> $cardsStorage
flock -x 200

found=0
while IFS=' ' read -r card groups; do
	if [[ $card = $readCard ]]; then
		read -a groups <<< $(IFS=','; echo $groups)

		printf "$card " >&200

		groupWritten=0
		for r in ${!requiredGroups[*]}; do
			[[ groupWritten -eq 1 ]] && printf "," >&200
			found=0
			for group in ${groups[*]}; do
				if [[ $group = ${requiredGroups[$r]} ]]; then
					found=1
					break
				fi
			done

			if [[ $found -eq 0 ]]; then
				printf ${requiredGroups[$r]} >&200
				groupWritten=1
			fi
		done

		for i in ${!groups[*]}; do
			[[ groupWritten -eq 1 || $i -ne 0 ]] && printf "," >&200
			printf ${groups[$i]}
		done

		printf "\n" >&200

		found=1
		continue
	fi

	printf "$card $groups\n" >&200
done <<< "$cards"

if [[ $found -eq 0 ]]; then
	printf "$readCard ${input[2]}\n" >&200
fi

flock -u 200
exec 200>&-

printf "OK\n"
