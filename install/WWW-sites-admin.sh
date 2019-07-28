#!/bin/bash

PHPMYADMIN_VERSION=4.8.5
PHPMYADMIN_SOURCE=$PHPMYADMIN_VERSION/phpMyAdmin-$PHPMYADMIN_VERSION-all-languages.tar.gz
PHPMYADMIN_FILE=phpMyAdmin-$PHPMYADMIN_VERSION-all-languages

#
# Admin sites
if [ "$INSTALL_ADMIN_WEBSITES" == "y" ]; then
	echoBanner "WWW admin sites"
	checkIfInstalled "www-admin-sites" "WWW admin sites"
	if [ "$?" == "0" ]; then
        # add to system hosts
        $WSLDP_GLOBAL_BIN_DIR/wsldp-hosts-add.sh $LOCAL_IP_ADDRESS $ADMIN_WEBSITE_SITENAME > /dev/null 2>&1
        addToMemoire "Added to system hosts: $LOCAL_IP_ADDRESS $ADMIN_WEBSITE_SITENAME"

        #
        mkdir -p $ADMIN_WEBSITE_ROOTDIR 2> /dev/null
        CWD=$(pwd)

        # phpMyAdmin
        cd $ADMIN_WEBSITE_ROOTDIR
        curl -s https://files.phpmyadmin.net/phpMyAdmin/$PHPMYADMIN_SOURCE  --output $PHPMYADMIN_FILE.tar.gz
        tar -zxvf $PHPMYADMIN_FILE.tar.gz > /dev/null
        rm $PHPMYADMIN_FILE.tar.gz 2> /dev/null
        rm -R mysql 2> /dev/null
        mv $PHPMYADMIN_FILE mysql
        cd mysql
        mv config.sample.inc.php config.inc.php 2> /dev/null
        SECRET=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)
        sed -i "s#\$cfg\['blowfish_secret'\] = '';#\$cfg\['blowfish_secret'\] = '$SECRET';#" config.inc.php
        sed -i "s#\$cfg\['Servers'\]\[\$i\]\['host'\] = 'localhost';#\$cfg\['Servers'\]\[\$i\]\['host'\] = '$DB_HOST';#" config.inc.php
# TODO - is it needed? (the tmp dir)
        mkdir tmp
        chmod a+w tmp
        echo "$DEFAULT_PHP_VERSION" > .php-version

        if [ "$INSTALL_SERVICE_APACHE2" == "y" ]; then
            cd $CWD
            cp ./resources/config/apache_admin_sites-local.conf /etc/apache2/sites-available/admin-sites-local.conf 2> /dev/null
            chmod 644 /etc/apache2/sites-available/admin-sites-local.conf
            sed -i "s#_LOCAL_#$ADMIN_WEBSITE_SITENAME#" /etc/apache2/sites-available/admin-sites-local.conf
            sed -i "s#_DEFAULT_PHP_VERSION_#$DEFAULT_PHP_VERSION#" /etc/apache2/sites-available/admin-sites-local.conf
            sed -i "s#_ADMIN_WEBSITE_ROOTDIR_#$ADMIN_WEBSITE_ROOTDIR#" /etc/apache2/sites-available/admin-sites-local.conf
            a2ensite admin-sites-local.conf > /dev/null
        fi

        if [ "$INSTALL_SERVICE_NGINX" == "y" ]; then
            cd $CWD
            cp ./resources/config/nginx_admin_sites-local.conf /etc/nginx/sites-available/admin-sites-local 2> /dev/null
            chmod 644 /etc/nginx/sites-available/admin-sites-local
            if [ "$RUNNING_ON" != "wsl" ]; then
                sed -i "s|fastcgi_buffering|#fastcgi_buffering|" /etc/nginx/sites-available/admin-sites-local
            fi
            sed -i "s#_LOCAL_#$ADMIN_WEBSITE_SITENAME#" /etc/nginx/sites-available/admin-sites-local
            sed -i "s#_ADMIN_WEBSITE_ROOTDIR_#$ADMIN_WEBSITE_ROOTDIR#" /etc/nginx/sites-available/admin-sites-local
            sed -i "s#_DEFAULT_PHP_VERSION_#$DEFAULT_PHP_VERSION#" /etc/nginx/sites-available/admin-sites-local
            sed -i "s/#_AUTOINDEX_/autoindex on;/" /etc/nginx/sites-available/admin-sites-local
            cd /etc/nginx/sites-enabled
            ln -s ../sites-available/admin-sites-local admin-sites-local 2> /dev/null
        fi
# TODO

        # opcache
        cd $ADMIN_WEBSITE_ROOTDIR
        # ...

        # redis
        cd $ADMIN_WEBSITE_ROOTDIR
        # ...

        # etc
        cd $ADMIN_WEBSITE_ROOTDIR
        # ...

        #
        chown -R $INSTALLED_FOR_USER:$INSTALLED_FOR_USER $ADMIN_WEBSITE_ROOTDIR 2> /dev/null
        cd $CWD
        setAsInstalled "www-admin-sites"
	fi
fi
