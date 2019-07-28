#!/bin/bash

#
# Drupal console launcher
if [ "$INSTALL_PHP" == "y" ] && [ "$INSTALL_DRUPAL_CONSOLE_LAUNCHER" == "y" ]; then
	echoBanner "PHP - Drupal console launcher"
	checkIfInstalled "php-drupal-console" "PHP - Drupal console launcher"
	if [ "$?" == "0" ]; then
		curl -sL https://drupalconsole.com/installer --output drupal.phar
		chmod +x drupal.phar
		mv drupal.phar $WSLDP_GLOBAL_BIN_DIR/drupal
		setAsInstalled "php-drupal-console"
	fi
fi
