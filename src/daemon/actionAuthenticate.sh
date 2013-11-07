#!/bin/bash

[[ ${#input[*]} -ne 2 ]] && printf "BAD_REQUEST\n" && continue

########## Search for the given username
found=0
while IFS=' ' read user cards; do
	read -a cards <<< $(IFS=','; echo $cards)

	if [[ $user = ${input[1]} ]]; then
		found=1
		break
	fi
done < $usersStorage

### Username not found
if [[ $found -eq 0 ]]; then
	printf "USER_NOT_FOUND\n"
	continue
fi


########## Username found, read a card
printf "INSERT_CARD\n"

# cardStatus: 0 => OK, 1 => invalid, 2 => timeout
cardStatus=0
while true; do
	### @todo read the card

	readCard="card1" #ok
	sleep 2

	inArray $readCard ${cards[@]}

	[[ $? -eq 1 ]] && cardStatus=1
	break
done

if [ $cardStatus -eq 0 ]; then
	found=0
	while IFS=' ' read card groups; do
		groupsStr=$groups
		read -a groups <<< $(IFS=','; echo $groups)

		if [[ $card = $readCard ]]; then
			found=1
			break
		fi
	done < $cardsStorage

	if [[ $found -eq 1 ]]; then
		read -a sessionKey <<< $(IFS=' '; date +%s%Ns | md5sum)

		exec 200>> $sessionsStorage
		flock -x 200
		IFS=',' echo "$sessionKey $user $groupsStr" >&200
		flock -u 200
		exec 200>&-
		
		printf "OK $sessionKey $groupsStr\n"
	else
		printf "OK\n"
	fi
elif [[ $cardStatus -eq 1 ]]; then
	printf "INVALID_CARD\n";
else
	printf "READ_TIMEOUT\n"
fi
