#!/bin/bash

. src/shared/config.sh
. src/shared/basicFunctions.sh

if [ "$1" != "startDaemon" ]; then
	touch $usersStorage $passwordStorage $cardsStorage
	> $sessionsStorage
	ncat -l -k localhost 9999 -c "$0 startDaemon"
	exit 0
fi

while IFS=' ' read -a input; do
	case ${input[0]} in
	HELLO)           printf "authenticate,logout,grant-user,grant-card,revoke-user,revoke-card,change-password\n" ;;
	authenticate)    . src/daemon/actionAuthenticate.sh ;;
	logout)          . src/daemon/actionLogout.sh ;;
	grant-user)      . src/daemon/actionGrantUser.sh ;;
	grant-card)      . src/daemon/actionGrantCard.sh ;;
	revoke-user)     . src/daemon/actionRevokeUser.sh ;;
	revoke-card)     . src/daemon/actionRevokeCard.sh ;;
	change-password) . src/daemon/actionChangePassword.sh ;;
	*)               printf "BAD_REQUEST\n" ;;
	esac
done

