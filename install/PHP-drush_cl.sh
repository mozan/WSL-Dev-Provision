#!/bin/bash

#
# Drush launcher
if [ "$INSTALL_PHP" == "y" ] && [ "$INSTALL_DRUSH_CONSOLE_LAUNCHER" == "y" ]; then
	echoBanner "PHP - Drush"
	checkIfInstalled "php-drush" "PHP - Drush"
	if [ "$?" == "0" ]; then
		curl -sL https://github.com/drush-ops/drush-launcher/releases/download/0.6.0/drush.phar --output drush.phar
		chmod +x drush.phar
		mv drush.phar $WSLDP_GLOBAL_BIN_DIR/drush
		drush self-update
		setAsInstalled "php-drush"
	fi
fi
