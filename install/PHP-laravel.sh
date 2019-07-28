#!/bin/bash

#
# Laravel Envoy, Installer, and prestissimo
if [ "$INSTALL_PHP" == "y" ] && [ "$INSTALL_PHP_MISC_DEVEL" == "y" ] && [ "$INSTALL_LARAVEL_COMMANDS" == "y" ]; then
	echoBanner "PHP - Laravel commands (envoy, laravel, lumen, spark)"
	checkIfInstalled "php-laravel" "PHP - Laravel commands (envoy, laravel, lumen, spark)"
	if [ "$?" == "0" ]; then
		composerInstall "hirak/prestissimo"
		composerInstall "laravel/envoy"
		composerInstall "laravel/installer"
		composerInstall "laravel/lumen-installer"
		composerInstall "laravel/spark-installer"
		installAliases ./resources/shell/bash_aliases_laravel
		setAsInstalled "php-laravel"
	fi
fi
