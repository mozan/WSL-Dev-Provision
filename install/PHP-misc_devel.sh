#!/bin/bash

#
# Misc PHP tools
if [ "$INSTALL_PHP" == "y" ] && [ "$INSTALL_PHP_MISC_DEVEL" == "y" ]; then
	echoBanner "PHP - misc tools"

	if [ "$INSTALL_BEHAT" == "y" ]; then
		echoBanner "PHP - behat"
		checkIfInstalled "php-behat" "PHP - behat"
		if [ "$?" == "0" ]; then
			composerInstall "behat/behat"
			setAsInstalled "php-behat"
		fi
	fi

	if [ "$INSTALL_PHING" == "y" ]; then
		echoBanner "PHP - phing"
		checkIfInstalled "php-phing" "PHP - phing"
		if [ "$?" == "0" ]; then
			curl -sL https://www.phing.info/get/phing-latest.phar --output phing.phar
			chmod +x phing.phar
			mv phing.phar $WSLDP_GLOBAL_BIN_DIR/phing
			setAsInstalled "php-phing"
		fi
	fi

	if [ "$INSTALL_PHP_CODESNIFFER" == "y" ]; then
		echoBanner "PHP - phpcodesniffer"
		checkIfInstalled "php-phpcodesniffer" "PHP - phpcodesniffer"
		if [ "$?" == "0" ]; then
			composerInstall "squizlabs/php_codesniffer=*"
			setAsInstalled "php-phpcodesniffer"
		fi
	fi

	if [ "$INSTALL_PHPDOC" == "y" ]; then
		echoBanner "PHP - phpdoc"
		checkIfInstalled "php-phpdoc" "PHP - phpdoc"
		if [ "$?" == "0" ]; then
			curl -sL http://www.phpdoc.org/phpDocumentor.phar --output phpDocumentor.phar
			chmod +x phpDocumentor.phar
			mv phpDocumentor.phar $WSLDP_GLOBAL_BIN_DIR/phpdoc
			setAsInstalled "php-phpdoc"
		fi
	fi

	if [ "$INSTALL_PHPINSIGHTS" == "y" ]; then
		echoBanner "PHP - phpinsights"
		checkIfInstalled "php-phpinsights" "PHP - phpinsights"
		if [ "$?" == "0" ]; then
			composerInstall "nunomaduro/phpinsights"
			setAsInstalled "php-phpinsights"
		fi
	fi

	if [ "$INSTALL_PHPSPEC" == "y" ]; then
		echoBanner "PHP - phpspec"
		checkIfInstalled "php-phpspec" "PHP - phpspec"
		if [ "$?" == "0" ]; then
			composerInstall "phpspec/phpspec"
			setAsInstalled "php-phpspec"
		fi
	fi

	if [ "$INSTALL_PHPSTAN" == "y" ]; then
		echoBanner "PHP - phpstan"
		checkIfInstalled "php-phpstan" "PHP - phpstan"
		if [ "$?" == "0" ]; then
			composerInstall "phpstan/phpstan"
			setAsInstalled "php-phpstan"
		fi
	fi

	if [ "$INSTALL_PHPUNIT" == "y" ]; then
		echoBanner "PHP - phpunit"
		checkIfInstalled "php-phpunit" "PHP - phpunit"
		if [ "$?" == "0" ]; then
			curl -sL https://phar.phpunit.de/phpunit-nightly.phar --output phpunit.phar
			chmod +x phpunit.phar
			mv phpunit.phar $WSLDP_GLOBAL_BIN_DIR/phpunit
			setAsInstalled "php-phpunit"
		fi
	fi
fi
