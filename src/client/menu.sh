#!/bin/bash

function showMainMenu() {

send "
Welcome to the RFID login client!
Please choose one of the available actions:
	1) Authenticate
	2) Logout certain user
	3) Grant user a card
	4) Assign group(s) to a card
	5) Revoke user a card(s)
	6) Remove group(s) from a card
	7) Change main password
	q) Exit the application
"
	choice=$(request "Please choose an action: " 1 2 3 4 5 6 7 q)

	case $choice in
	1) echo "authenticate" ;;
	2) echo "logout" ;;
	3) echo "grantUser" ;;
	4) echo "grantCard" ;;
	5) echo "revokeUser" ;;
	6) echo "revokeCard" ;;
	7) echo "change-password" ;;
	q) echo "quit" ;;
	esac
}
