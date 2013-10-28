#!/bin/bash

. src/shared/config.sh
. src/shared/basicFunctions.sh
. src/client/errorHandling.sh
. src/client/connectDaemon.sh
. src/client/menu.sh


# > $usersStorage
# echo "grongor testgroup,testgroup2" >> $usersStorage
# echo "someone testgroup" >> $usersStorage
# echo "root testgroup,testgroup2,testgroup3" >> $usersStorage













while true; do
	action=$(showMainMenu)

	case $action in
	authenticate)    . src/client/actionAuthenticate.sh ;;
	logout)          . src/client/actionLogout.sh ;;
	grant)           . src/client/actionGrant.sh ;;
	revoke)          . src/client/actionRevoke.sh ;;
	change-password) . src/client/actionChangePassword.sh ;;
	quit)            exit 0 ;;
	esac
done

printf "we are out of menu!\n\n"

exit 0



#su $(id -nu)
id -nG
$SHELL -c "su $(id -nu)"
id -nG
echo Prace ukoncena
