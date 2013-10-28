#!/bin/bash

if [[ ${#input[*]} -ne 2 && ${#input[*]} -ne 3 ]]; then
	printf "BAD_REQUEST\n"
	continue
fi

all=0
if [[ ${#input[*]} -eq 3 ]]; then
	all=1
	mainPwd=$(cat $passwordStorage)
	read -a inputPwd <<< $(IFS=' '; sha512sum <<< ${input[2]})

	if [[ $mainPwd != $inputPwd ]]; then
		printf "INVALID_PWD\n"
		continue
	fi
fi

sessions=$(cat $sessionsStorage)
exec 200> $sessionsStorage
flock -x 200

found=0
while read -r key user groups; do
	if [[ $all -eq 0 && "$key" = "${input[1]}" || $all -eq 1 && "$user" = "${input[1]}" ]]; then
		found=1
		continue
	fi

	printf "$key $user $groups\n" >&200
done <<< "$sessions"

flock -u 200
exec 200>&-

if [[ $found -eq 0 ]]; then
	if [[ $all -eq 0 ]]; then
		printf "INVALID_KEY\n"
	else
		printf "USER_NOT_FOUND\n"
	fi
else
	printf "OK\n"
fi