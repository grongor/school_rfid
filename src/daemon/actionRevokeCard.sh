#!/bin/bash

[[ ${#input[*]} -ne 3 ]] && printf "BAD_REQUEST\n" && continue

########## Check main password
mainPwd=$(cat $passwordStorage)
read -a inputPwd <<< $(IFS=' '; sha512sum <<< ${input[2]})

if [[ $mainPwd != $inputPwd ]]; then
	printf "INVALID_PWD\n"
	continue
fi

########## Check existance of the groups or set allGroups=1
if [[ ${input[1]} = "allGroups" ]]; then
	allGroups=1
else
	allGroups=0
	read -a requiredGroups <<< $(IFS=','; echo ${input[1]})
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
		printf "INVALID_GROUP ${missingGroups[*]}\n"
		continue
	fi
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

########## Add group(s) to the card
cards=$(cat $cardsStorage)
#exec 200> $cardsStorage
#flock -x 200

missingGroups=""
while IFS=' ' read -r card groups; do
	if [[ $card = $readCard ]]; then
		if [[ $allGroups -eq 1 ]]; then
			found=1
			continue
		fi
		read -a groups <<< $(IFS=','; echo $groups)

		for r in ${!requiredGroups[*]}; do
			found=0
			for group in ${groups[*]}; do
				if [[ $group = ${requiredGroups[$r]} ]]; then
					found=1
					break
				fi
			done

			if [[ $found -eq 0 ]]; then
				missingGroups="$missingGroups,${requiredGroups[$r]}"
			fi
		done

		if [[ -z $missingGroups ]]; then
			groupsToBeWritten=""
			for group in ${groups[*]}; do
				found=0
				for r in ${!requiredGroups[*]}; do
					if [[ $group = ${requiredGroups[$r]} ]]; then
						found=1
						break
					fi
				done

				if [[ $found -eq 0 ]]; then
					groupsToBeWritten="$groupsToBeWritten,$group"
				fi
			done

			printf "$card ${groupsToBeWritten[*]:1}\n" >&200
			continue
		fi
	fi

	printf "$card $groups\n" >&200
done <<< "$cards"

if [[ -n $missingGroups ]]; then
	printf "GROUP_NOT_IN_CARD ${missingGroups[*]:1}\n" >&200
	continue
fi

flock -u 200
exec 200>&-

printf "OK\n"
