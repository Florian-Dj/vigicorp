#!/bin/bash

# Create user and folder /www
create_user () {
	egrep "^$1" /etc/passwd >/dev/null
	if [ $? -eq 0 ]; then
		echo "User $1 exists!"
	else
		adduser --home /home/test-"$1".vigicorp.net --shell /bin/bash --disabled-password $1
		echo "User $1 has been added to system!" || echo "Failed to add a user!"
		mkdir /home/test-"$1".vigicorp.net/www
		cp index.php /home/test-"$1".vigicorp.net/www/
		chown -R $1: /home/test-"$1".vigicorp.net
	fi
}

#Install apache2
install_apache () {
	apt -y install lsb-release apt-transport-https ca-certificates wget apache2
	wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg
	echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" | sudo tee /etc/apt/sources.list.d/php.list
	apt update -y
	systemctl start apache2
	systemctl enable apache2
}

#Install php librairies for apache2
install_php () {
	apt install -y $1 $1-cli $1-common
	apt install -y libapache2-mod-$1
}

# Am i Root user?
if [ $(id -u) -eq 0 ]; then
	apt update && apt upgrade -y
	create_user 'php7'
	create_user 'php8'
	install_apache
	install_php 'php7.4'
	install_php 'php8.0'
else
	echo "Only root may add a user to the system."
	exit 2
fi