#!/bin/bash

#
# Apache
if [ "$INSTALL_WWW_SERVERS" == "y" ] && [ "$INSTALL_SERVICE_APACHE2" == "y" ]; then
	echoBanner "WWW - Apache 2"
	checkIfInstalled "www-apache2" "WWW - Apache2"
	if [ "$?" == "0" ]; then
		apt-get $APT_SILENCE install -y --allow-downgrades --allow-remove-essential --allow-change-held-packages apache2 libapache2-mod-fcgid
		if [ "$INSTALL_PHP_56" == "y" ]; then
			apt-get $APT_SILENCE install -y apache2 php5.6-cgi
		fi
		if [ "$INSTALL_PHP_70" == "y" ]; then
			apt-get $APT_SILENCE install -y apache2 php7.0-cgi
		fi
		if [ "$INSTALL_PHP_71" == "y" ]; then
			apt-get $APT_SILENCE install -y apache2 php7.1-cgi
		fi
		if [ "$INSTALL_PHP_72" == "y" ]; then
			apt-get $APT_SILENCE install -y apache2 php7.2-cgi
		fi
		if [ "$INSTALL_PHP_73" == "y" ]; then
			apt-get $APT_SILENCE install -y apache2 php7.3-cgi
		fi

		sed -i "s/www-data/$INSTALLED_FOR_USER/" /etc/apache2/envvars

		a2dissite 000-default > /dev/null
		a2dissite default-ssl > /dev/null

		# Enable FPM
		if [ "$INSTALL_SERVICE_PHPFPM" == "y" ]; then
			a2enconf php$DEFAULT_PHP_VERSION-fpm > /dev/null
		fi
		# Assume user wants mode_rewrite support
		a2enmod rewrite > /dev/null
		# Turn on HTTPS support
		a2enmod ssl > /dev/null
		# Turn on proxy & fcgi
		a2enmod proxy proxy_fcgi > /dev/null
		# Turn on headers support
		a2enmod headers actions alias > /dev/null

		if [ -z "$(grep '^Mutex posixsem$' /etc/apache2/apache2.conf)" ]
		then
		    echo "Mutex posixsem" >> /etc/apache2/apache2.conf
		fi

		# copy scripts to WSLDP_GLOBAL_BIN_DIR
		cp ./resources/bin/wsldp-create-site-apache.sh $WSLDP_GLOBAL_BIN_DIR/ 2> /dev/null
# TODO
		setEnvWSLDPScriptsGlobals WSLDP_GLOBAL_CONFIG_DIR $WSLDP_GLOBAL_CONFIG_DIR $WSLDP_GLOBAL_BIN_DIR/wsldp-create-site-apache.sh

		sed -i "s#/etc/apache2/ssl#$WSLDP_GLOBAL_CONFIG_DIR/certificates#" $WSLDP_GLOBAL_BIN_DIR/wsldp-create-site-apache.sh
		sed -i "s#LOCAL_IP_ADDRESS=127.0.0.1#LOCAL_IP_ADDRESS=$LOCAL_IP_ADDRESS#" $WSLDP_GLOBAL_BIN_DIR/wsldp-create-site-apache.sh
		sed -i "s#WSLDP_GLOBAL_BIN_DIR=/usr/local/bin#WSLDP_GLOBAL_BIN_DIR=$WSLDP_GLOBAL_BIN_DIR#" $WSLDP_GLOBAL_BIN_DIR/wsldp-create-site-apache.sh

		# install aliases
		installAliases ./resources/shell/bash_aliases_apache

		autorunService "apache2"
		setAsInstalled "www-apache2"
	fi
fi
