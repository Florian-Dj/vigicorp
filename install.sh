#!/bin/bash

# Create user and folder /www
create_user () {
	#User php7
	egrep "^$1" /etc/passwd >/dev/null
	if [ $? -eq 0 ]; then
		echo "User $1 exists!"
	else
	    adduser --home /home/test-"$1".vigicorp.net --shell /bin/bash --disabled-password $1
		echo "User $1 has been added to system!" || echo "Failed to add a user!"
	fi
}

# Am i Root user?
if [ $(id -u) -eq 0 ]; then
    apt update && apt upgrade -y
    create_user 'php7'
    create_user 'php8'
    mkdir /home/test-php{7,8}.vigicorp.net/www
else
	echo "Only root may add a user to the system."
	exit 2
fi