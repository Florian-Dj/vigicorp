#!/bin/bash

# Create user manual
create_user () {
	read -p "Enter username : " username
	read -p "Enter home directory : " directory
	egrep "^$username" /etc/passwd >/dev/null
	if [ $? -eq 0 ]; then
		echo "$username exists!"
	else
		adduser --home /home/$directory --shell /usr/sbin/nologin --disabled-password $username
		mkdir /home/$directory/www
		cp index.php /home/$directory/www/
		chown -R $username: /home/$directory
		echo "User $username has been added to system!" || echo "Failed to add a user!"
	fi
	main_menu
}

# Menu choice php version
menu_php_version () {
	echo """
	1 - PHP 8.0
	2 - PHP 7.4
	3 - PHP 7.3
	0 - Back"""
	read -p "Enter choice : " choice_php_menu
	case $choice_php_menu in
		1) install_php "php8" ;;
		2) install_php "php7.4" ;;
		3) install_php "php7.3" ;;
		0) main_menu ;;
		*) echo "Bad error" && menu_php ;;
	esac
}

# Install php version
install_php () {
	apt install -yqq $1 $1-cli $1-common $1-fpm
	apt install -yqq libapache2-mod-$1
	systemctl start $1-fpm
	systemctl enable $1-fpm
	echo "Install, start and enable $1"
	menu_php_version
}

# Create new web site
create_website (){
	read -p "Enter domain : " domain
	read -p "Enter directory : " directory
	read -p "Enter php version : " php_version
	cp your_domain.conf /etc/apache2/sites-available/$domain.conf
	sed -i 's/php_version/'$php_version'/g' /etc/apache2/sites-available/$domain.conf
	sed -i 's/domain/'$domain'/g' /etc/apache2/sites-available/$domain.conf
	sed -i 's|path_directory|'$directory'|g' /etc/apache2/sites-available/$domain.conf
	a2ensite $domain
	echo "Configuration apache file for $domain"
	main_menu
}

# Install Auto and Manual
# Install Apache2
install_apache () {
	apt -yqq install lsb-release apt-transport-https ca-certificates apache2 libapache2-mod-fcgid wget
	wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg
	echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" | sudo tee /etc/apt/sources.list.d/php.list
	apt update -yqq
	systemctl start apache2
	systemctl enable apache2
	cat apache.conf > /etc/apache2/apache2.conf
	echo "Install and start apache2"
	if [ -z $1 ]; then
		main_menu
	fi
}

# Install Auto
# Install PHP librairies for Apache2
install_php_auto () {
	apt install -yqq $1 $1-cli $1-common $1-fpm
	apt install -yqq libapache2-mod-$1
	cp your_domain.conf /etc/apache2/sites-available/$2.conf
	sed -i 's/php_version/'$1'/g' /etc/apache2/sites-available/$2.conf
	sed -i 's/domain/'$2'/g' /etc/apache2/sites-available/$2.conf
	sed -i 's|path_directory|'$3'|g' /etc/apache2/sites-available/$2.conf
	a2ensite $2
	echo "Install $1 and configuration apache file"
}

# Install Auto
# Create user auto and folder /www
create_user_auto () {
	egrep "^$1" /etc/passwd >/dev/null
	if [ $? -eq 0 ]; then
		echo "User $1 exists!"
	else
		adduser --home /home/test-"$1".vigicorp.net --shell /usr/sbin/nologin --disabled-password $1
		mkdir /home/test-"$1".vigicorp.net/www
		cp index.php /home/test-"$1".vigicorp.net/www/
		chown -R $1: /home/test-"$1".vigicorp.net
		echo "User $1 has been added to system!" || echo "Failed to add a user!"
	fi
}

# Install Auto
# Auto install full projet
install_auto () {
	apt update -qq && apt upgrade -yqq && apt autoremove -yqq
	create_user_auto 'php7'
	create_user_auto 'php8'
	install_apache 'auto'
	install_php_auto 'php7.4' 'test-php7.vigicorp.net' '/home/test-php7.vigicorp.net/www'
	install_php_auto 'php8.0' 'test-php8.vigicorp.net' '/home/test-php8.vigicorp.net/www'
	systemctl reload apache2
	echo "Auto Install Completed !"
}

# Main menu for user
main_menu () {
	echo """
	1 - Create User
	2 - Install Apache2
	3 - Install PHP version
	4 - Create new website
	5 - Install auto
	0 - Exit"""
	read -p "Enter choice : " choice_main_menu
	case $choice_main_menu in
		1) create_user ;;
		2) install_apache ;;
		3) menu_php_version ;;
		4) create_website ;;
		5) install_auto ;;
		0) exit 1 ;;
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