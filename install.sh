#!/bin/bash

# Create user and folder /www
create_user () {
	sudo useradd -d /home/test-php7.vigicorp.net -s /bin/bash php7
	sudo useradd -d /home/test-php8.vigicorp.net -s /bin/bash php8
	[ $? -eq 0 ] && echo "User php7 and php8 has been added to system!"
    sudo mkdir /home/test-php{7,8}.vigicorp.net/www
}

# Am i Root user?
if [ $(id -u) -eq 0 ] || [ $(whoami) = "debian" ]; then
    sudo apt update && sudo apt upgrade
    create_user
else
	echo "Only root or debian may add a user to the system."
	exit 2
fi