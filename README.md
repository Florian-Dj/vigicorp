## Prérequis

 - Debian 10


## But

- Installation d’un serveur web Apache et multi versions PHP (7.4 et 8.0, les deux versions doivent cohabiter) permettant d’afficher PHP Info de chaque version.


## Pratique

- Créer un utilisateur php7avec comme home directory /home/test-php7.vigicorp.net
- Dans le home directory créer un dossier www
- Dans le dossier www créer un fichier php index.php avec le code permettant d’afficher PHP Info
- Créer un utilisateur php8 avec comme home directory /home/test-php8.vigicorp.net
- Dans le home directory créer un dossier www
- Dans le dossier www créer un fichier php index.php avec le code permettant d’afficher PHP Info
- Installer et configurer Apache, PHP7.4 et PHP8.0
- Configurer Apache pour qu’il affiche la page index.php de l’utilisateur test-php7 sur l’adresse http://test-php7.vigicorp.net ainsi que la page index.php de l’utilisateur test-php8 sur l’adresse http://test-php8.vigicorp.net
- Sécurisez l'accès au serveur


## Installation

Vous devez être root pour pouvoir lancer le script.

```
apt install -y git
git clone https://github.com/Florian-Dj/vigicorp
cd vigicorp/
chmod 754 install.sh
sh install.sh
```

Il vous suffit juste de faire votre choix d'installation suivant vos besoins.