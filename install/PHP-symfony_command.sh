#!/bin/bash

#
# Symfony symfony command
if [ "$INSTALL_PHP" == "y" ] && [ "$INSTALL_PHP_MISC_DEVEL" == "y" ] && [ "$INSTALL_SYMFONY_COMMAND" == "y" ]; then
	echoBanner "PHP symfony command"
	checkIfInstalled "php-symfony" "PHP symfony command"
	if [ "$?" == "0" ]; then
		curl -sL https://get.symfony.com/cli/installer | bash -
		if test -f $HOME/.symfony/bin/symfony; then
			mv $HOME/.symfony/bin/symfony $WSLDP_GLOBAL_BIN_DIR/symfony
			chown -R $INSTALLED_AS_USER:$INSTALLED_AS_USER $INSTALLED_AS_HOME/.symfony
			chown $INSTALLED_FOR_USER:$INSTALLED_FOR_USER $WSLDP_GLOBAL_BIN_DIR/symfony
		fi
		installAliases ./resources/shell/bash_aliases_symfony
		setAsInstalled "php-symfony"
	fi
fi
