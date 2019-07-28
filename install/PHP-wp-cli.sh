#!/bin/bash

#
# wp-cli
if [ "$INSTALL_PHP" == "y" ] && [ "$INSTALL_WP_CLI" == "y" ]; then
	echoBanner "PHP Wordpress CLI"
	checkIfInstalled "php-wordpress-cli" "PHP Wordpress CLI"
	if [ "$?" == "0" ]; then
		curl -sL https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar --output wp-cli.phar
		chmod +x wp-cli.phar
		mv wp-cli.phar $WSLDP_GLOBAL_BIN_DIR/wp
		setAsInstalled "php-wordpress-cli"
	fi
fi
