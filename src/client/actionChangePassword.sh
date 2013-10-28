#!/bin/bash

old=$(requestPassword "\n\nCurrent main password: ")
new=$(requestPassword "\nNew main password: ")
newAgain=$(requestPassword "\nNew main password again: ")

if [[ "$new" != "$newAgain" ]]; then
	send "\n\nYour new passwords doesn't match.\nAction canceled.\n"
	pause
	continue
fi

reply=$(queryDaemon change-password "$old" "$new")

case $reply in
INVALID_OLD_PWD) send "\n\nCurrent password you've entered is invalid.\nAction canceled.\n" ;;
INVALID_PWD)     send "\n\nNew password you've entered is invalid.\nAction canceled.\n" ;;
OK)              send "\n\nYour main password was succesfully changed.\n" ;;
esac

pause