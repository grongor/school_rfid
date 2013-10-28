#!/bin/bash

[[ ${#input[*]} -ne 3 ]] && printf "BAD_REQUEST\n" && continue

read -a oldHashedInput <<< $(IFS=' '; sha512sum <<< ${input[1]})

oldHashed=$(cat $passwordStorage)

if [[ $oldHashed != $oldHashedInput ]]; then
	printf "INVALID_OLD_PWD\n"
	continue
fi

if [[ ${#input[2]} -lt $minPasswordLen ]]; then
	printf "INVALID_PWD\n"
	continue
fi

read -a newHashedInput <<< $(IFS=' '; sha512sum <<< ${input[2]})

echo $newHashedInput > $passwordStorage
printf "OK\n"
