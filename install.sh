#!/bin/bash

# Create user 
create_user () {
	read -p "Enter username : " username
	read -p "Enter home directory : " directory
	egrep "^$username" /etc/passwd >/dev/null
	if [ $? -eq 0 ]; then
		echo "$username exists!"
	else
		adduser --home /home/$directory --shell /bin/bash --disabled-password $username
		mkdir /home/$directory/www
		cp index.php /home/$directory/www/
		chown -R $1: /home/$directory
		echo "User $1 has been added to system!" || echo "Failed to add a user!"
	fi
	main_menu
}

# Install apache2
install_apache () {
	apt -yqq install lsb-release apt-transport-https ca-certificates apache2 libapache2-mod-fcgid wget
	wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg
	echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" | sudo tee /etc/apt/sources.list.d/php.list
	apt update -yqq
	systemctl start apache2
	systemctl enable apache2
	cat apache.conf >> /etc/apache2/apache2.conf
	echo "Install and start apache2"
	if [ -z $1 ]; then
		main_menu
	fi
}

# Install php librairies for apache2
install_php () {
	apt install -yqq $1 $1-cli $1-common $1-fpm
	apt install -yqq libapache2-mod-$1
	cp your_domain.conf /etc/apache2/sites-available/$2.conf
	sed -i 's/php_version_full/'$1'/g' /etc/apache2/sites-available/$2.conf
	sed -i 's/php_version/'$2'/g' /etc/apache2/sites-available/$2.conf
	a2ensite $2
	echo "Install $1 and configuration apache file"
}

# Install Auto
# Auto install full projet
install_auto () {
	apt update -qq && apt upgrade -yqq && apt autoremove -yqq
	create_user_auto 'php7'
	create_user_auto 'php8'
	install_apache 'auto'
	install_php 'php7.4' 'php7'
	install_php 'php8.0' 'php8'
	systemctl reload apache2
	echo "Auto  Install Completed !"
}

# Install Auto
# Create user auto and folder /www
create_user_auto () {
	egrep "^$1" /etc/passwd >/dev/null
	if [ $? -eq 0 ]; then
		echo "User $1 exists!"
	else
		adduser --home /home/test-"$1".vigicorp.net --shell /bin/bash --disabled-password $1
		mkdir /home/test-"$1".vigicorp.net/www
		cp index.php /home/test-"$1".vigicorp.net/www/
		chown -R $1: /home/test-"$1".vigicorp.net
		echo "User $1 has been added to system!" || echo "Failed to add a user!"
	fi
}

# Main menu for user
main_menu () {
	echo """
	1 - Create user
	2 - Install apache2
	3 - Install Php version
	4 - Install auto
	0 - Exit"""
	read -p "Choose : " choose_main_menu
	case $choose_main_menu in
		1) create_user ;;
		2) install_apache ;;
		3) echo "Install Php version" ;;
		4) install_auto ;;
		0) exit 1;;
		*) echo "Bad error" && main_menu ;;
	esac
}

# Am i Root user?
if [ $(id -u) -eq 0 ]; then
	main_menu
else
	echo "Only root may add a user to the system."
	exit 2
fi