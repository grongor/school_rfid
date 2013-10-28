#!/bin/bash

function showMainMenu() {

send "
Welcome to the RFID login client!
Please choose one of the available actions:
	1) Authenticate
	2) Logout certain user
	3) Grant privileges
	4) Revoke privileges
	5) Change main password
	q) Exit the application
"
	choice=$(request "Please choose an action: " 1 2 3 4 5 q)

	case $choice in
	1) echo "authenticate" ;;
	2) echo "logout" ;;
	3) echo "grant" ;;
	4) echo "revoke" ;;
	5) echo "change-password" ;;
	q) echo "quit" ;;
	esac
}
