#!/bin/bash

CWD=$(pwd)

installMongo () {
	cd /usr/src/mongo-php-driver
	phpize$1
	./configure --with-php-config=/usr/bin/php-config$1 > /dev/null
	make clean > /dev/null
	make > /dev/null 2>&1
	make install > /tmp/mongod_dir

	cat /tmp/mongod_dir | cut -d' ' -f 8
	MONGO_DIR=$(cat /tmp/mongod_dir | grep "Installing shared extensions" | cut -d' ' -f 8)
	mv $MONGO_DIR/mongodb.so $MONGO_DIR/mongodb$1.so
	rm /tmp/mongod_dir

	chmod 644 $MONGO_DIR/mongodb$1.so
	bash -c "echo 'extension=mongodb$1.so' > /etc/php/$1/mods-available/mongo.ini"
	ln -s /etc/php/$1/mods-available/mongo.ini /etc/php/$1/cli/conf.d/20-mongo.ini 2> /dev/null
	ln -s /etc/php/$1/mods-available/mongo.ini /etc/php/$1/fpm/conf.d/20-mongo.ini 2> /dev/null
	cd $CWD
}

installFPM () {
	echoBanner "PHP-FPM $1"
	checkIfInstalled "php$1-fpm" "PHP-FPM $1"
	if [ "$?" == "0" ]; then
		apt-get $APT_SILENCE install -y --allow-downgrades --allow-remove-essential --allow-change-held-packages php$1-fpm

		echo "xdebug.remote_enable = 1" >> /etc/php/$1/mods-available/xdebug.ini
		echo "xdebug.remote_connect_back = 1" >> /etc/php/$1/mods-available/xdebug.ini
		echo "xdebug.remote_port = 9000" >> /etc/php/$1/mods-available/xdebug.ini
		echo "xdebug.max_nesting_level = 512" >> /etc/php/$1/mods-available/xdebug.ini
		echo "opcache.revalidate_freq = 0" >> /etc/php/$1/mods-available/opcache.ini

		sed -i "s/error_reporting = .*/error_reporting = E_ALL/" /etc/php/$1/fpm/php.ini
		sed -i "s/display_errors = .*/display_errors = On/" /etc/php/$1/fpm/php.ini
		sed -i "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/" /etc/php/$1/fpm/php.ini
		sed -i "s/memory_limit = .*/memory_limit = 512M/" /etc/php/$1/fpm/php.ini
		sed -i "s/upload_max_filesize = .*/upload_max_filesize = 100M/" /etc/php/$1/fpm/php.ini
		sed -i "s/post_max_size = .*/post_max_size = 100M/" /etc/php/$1/fpm/php.ini
		sed -i "s/;date.timezone.*/date.timezone = ${DEFAULT_TIMEZONE//\//\\/}/" /etc/php/$1/fpm/php.ini
		printf "[openssl]\n" | tee -a /etc/php/$1/fpm/php.ini
		printf "openssl.cainfo = /etc/ssl/certs/ca-certificates.crt\n" | tee -a /etc/php/$1/fpm/php.ini
		printf "[curl]\n" | tee -a /etc/php/$1/fpm/php.ini
		printf "curl.cainfo = /etc/ssl/certs/ca-certificates.crt\n" | tee -a /etc/php/$1/fpm/php.ini
		sed -i "s/user = www-data/user = $INSTALLED_FOR_USER/" /etc/php/$1/fpm/pool.d/www.conf
		sed -i "s/group = www-data/group = $INSTALLED_FOR_USER/" /etc/php/$1/fpm/pool.d/www.conf
		sed -i "s/listen\.owner.*/listen.owner = $INSTALLED_FOR_USER/" /etc/php/$1/fpm/pool.d/www.conf
		sed -i "s/listen\.group.*/listen.group = $INSTALLED_FOR_USER/" /etc/php/$1/fpm/pool.d/www.conf
		sed -i "s/;listen\.mode.*/listen.mode = 0666/" /etc/php/$1/fpm/pool.d/www.conf
		setAsInstalled "php$1-fpm"
	fi
}

#
# PHP
if [ "$INSTALL_PHP" == "y" ]; then
	echoBanner "PHP stuff"

	if [ "$INSTALL_DB_SERVERS" == "y" ] && [ "$INSTALL_SERVICE_MONGOD" == "y" ]; then
		rm -rf /tmp/mongo-php-driver /usr/src/mongo-php-driver
# TODO mongo version - why 1.5.2 ?!
		git clone -c advice.detachedHead=false -q -b '1.5.2' --single-branch https://github.com/mongodb/mongo-php-driver /tmp/mongo-php-driver
		mv /tmp/mongo-php-driver /usr/src/mongo-php-driver
		cd /usr/src/mongo-php-driver
		git submodule -q update --init
		cd $CWD
	fi

	if [ "$INSTALL_PHP_56" == "y" ]; then
		echoBanner "PHP 5.6"
		checkIfInstalled "php5.6" "PHP 5.6"
		if [ "$?" == "0" ]; then
			apt-get $APT_SILENCE install -y --allow-downgrades --allow-remove-essential --allow-change-held-packages \
			php5.6-cli php5.6-cgi php5.6-dev php5.6-pgsql php5.6-sqlite3 php5.6-gd php5.6-curl php5.6-imap php5.6-mysql php5.6-common \
			php5.6-mbstring php5.6-xml php5.6-zip php5.6-bcmath php5.6-soap php5.6-intl php5.6-readline php5.6-ldap php5.6-dev \
			php-xdebug php-memcached php-pear php-apcu php-amqp

			sed -i "s/error_reporting = .*/error_reporting = E_ALL/" /etc/php/5.6/cli/php.ini
			sed -i "s/display_errors = .*/display_errors = On/" /etc/php/5.6/cli/php.ini
			sed -i "s/memory_limit = .*/memory_limit = 512M/" /etc/php/5.6/cli/php.ini
			sed -i "s/;date.timezone.*/date.timezone = ${DEFAULT_TIMEZONE//\//\\/}/" /etc/php/5.6/cli/php.ini

			# Disable xdebug on CLI
			if [ "$DISABLE_XDEBUG_ON_CLI" == "y" ]; then
				phpdismod -s cli xdebug
			fi
			setAsInstalled "php5.6"

			if [ "$INSTALL_SERVICE_PHPFPM" == "y" ]; then
				installFPM "5.6"
			fi

			if [ "$INSTALL_DB_SERVERS" == "y" ] && [ "$INSTALL_SERVICE_MONGOD" == "y" ]; then
				installMongo "5.6"
			fi
		fi
	fi

	if [ "$INSTALL_PHP_70" == "y" ]; then
		echoBanner "PHP 7.0"
		checkIfInstalled "php7.0" "PHP 7.0"
		if [ "$?" == "0" ]; then
			apt-get $APT_SILENCE install -y --allow-downgrades --allow-remove-essential --allow-change-held-packages \
			php7.0-cli php7.0-cgi php7.0-dev php7.0-pgsql php7.0-sqlite3 php7.0-gd php7.0-curl php7.0-imap php7.0-mysql php7.0-common \
			php7.0-mbstring php7.0-xml php7.0-zip php7.0-bcmath php7.0-soap php7.0-intl php7.0-readline php7.0-ldap php7.0-dev \
			php-xdebug php-memcached php-pear php-apcu php-amqp

			sed -i "s/error_reporting = .*/error_reporting = E_ALL/" /etc/php/7.0/cli/php.ini
			sed -i "s/display_errors = .*/display_errors = On/" /etc/php/7.0/cli/php.ini
			sed -i "s/memory_limit = .*/memory_limit = 512M/" /etc/php/7.0/cli/php.ini
			sed -i "s/;date.timezone.*/date.timezone = ${DEFAULT_TIMEZONE//\//\\/}/" /etc/php/7.0/cli/php.ini

			# Disable xdebug on CLI
			if [ "$DISABLE_XDEBUG_ON_CLI" == "y" ]; then
				phpdismod -s cli xdebug
			fi
			setAsInstalled "php7.0"

			if [ "$INSTALL_SERVICE_PHPFPM" == "y" ]; then
				installFPM "7.0"
			fi

			if [ "$INSTALL_DB_SERVERS" == "y" ] && [ "$INSTALL_SERVICE_MONGOD" == "y" ]; then
				installMongo "7.0"
			fi
		fi
	fi

	if [ "$INSTALL_PHP_71" == "y" ]; then
		echoBanner "PHP 7.1"
		checkIfInstalled "php7.1" "PHP 7.1"
		if [ "$?" == "0" ]; then
			apt-get $APT_SILENCE install -y --allow-downgrades --allow-remove-essential --allow-change-held-packages \
			php7.1-cli php7.1-cgi php7.1-dev php7.1-pgsql php7.1-sqlite3 php7.1-gd php7.1-curl php7.1-imap php7.1-mysql php7.1-common \
			php7.1-mbstring php7.1-xml php7.1-zip php7.1-bcmath php7.1-soap php7.1-intl php7.1-readline php7.1-ldap php7.1-dev \
			php-xdebug php-memcached php-pear php-apcu php-amqp

			sed -i "s/error_reporting = .*/error_reporting = E_ALL/" /etc/php/7.1/cli/php.ini
			sed -i "s/display_errors = .*/display_errors = On/" /etc/php/7.1/cli/php.ini
			sed -i "s/memory_limit = .*/memory_limit = 512M/" /etc/php/7.1/cli/php.ini
			sed -i "s/;date.timezone.*/date.timezone = ${DEFAULT_TIMEZONE//\//\\/}/" /etc/php/7.1/cli/php.ini

			# Disable xdebug on CLI
			if [ "$DISABLE_XDEBUG_ON_CLI" == "y" ]; then
				phpdismod -s cli xdebug
			fi
			setAsInstalled "php7.1"

			if [ "$INSTALL_SERVICE_PHPFPM" == "y" ]; then
				installFPM "7.1"
			fi

			if [ "$INSTALL_DB_SERVERS" == "y" ] && [ "$INSTALL_SERVICE_MONGOD" == "y" ]; then
				installMongo "7.1"
			fi
		fi
	fi

	if [ "$INSTALL_PHP_72" == "y" ]; then
		echoBanner "PHP 7.2"
		checkIfInstalled "php7.2" "PHP 7.2"
		if [ "$?" == "0" ]; then
			apt-get $APT_SILENCE install -y --allow-downgrades --allow-remove-essential --allow-change-held-packages \
			php7.2-cli php7.2-cgi php7.2-dev php7.2-pgsql php7.2-sqlite3 php7.2-gd php7.2-curl php7.2-imap php7.2-mysql php7.2-common \
			php7.2-mbstring php7.2-xml php7.2-zip php7.2-bcmath php7.2-soap php7.2-intl php7.2-readline php7.2-ldap php7.2-dev \
			php-xdebug php-memcached php-pear php-apcu php-amqp

			sed -i "s/error_reporting = .*/error_reporting = E_ALL/" /etc/php/7.2/cli/php.ini
			sed -i "s/display_errors = .*/display_errors = On/" /etc/php/7.2/cli/php.ini
			sed -i "s/memory_limit = .*/memory_limit = 512M/" /etc/php/7.2/cli/php.ini
			sed -i "s/;date.timezone.*/date.timezone = ${DEFAULT_TIMEZONE//\//\\/}/" /etc/php/7.2/cli/php.ini

			# Disable xdebug on CLI
			if [ "$DISABLE_XDEBUG_ON_CLI" == "y" ]; then
				phpdismod -s cli xdebug
			fi
			setAsInstalled "php7.2"

			if [ "$INSTALL_SERVICE_PHPFPM" == "y" ]; then
				installFPM "7.2"
			fi

			if [ "$INSTALL_DB_SERVERS" == "y" ] && [ "$INSTALL_SERVICE_MONGOD" == "y" ]; then
				installMongo "7.2"
			fi
		fi
	fi

	if [ "$INSTALL_PHP_73" == "y" ]; then
		echoBanner "PHP 7.3"
		checkIfInstalled "php7.3" "PHP 7.3"
		if [ "$?" == "0" ]; then
			apt-get $APT_SILENCE install -y --allow-downgrades --allow-remove-essential --allow-change-held-packages \
			php7.3-cli php7.3-cgi php7.3-dev php7.3-pgsql php7.3-sqlite3 php7.3-gd php7.3-curl php7.3-imap php7.3-mysql php7.3-common \
			php7.3-mbstring php7.3-xml php7.3-zip php7.3-bcmath php7.3-soap php7.3-intl php7.3-readline php7.3-ldap php7.3-dev \
			php-xdebug php-memcached php-pear php-apcu php-amqp

			sed -i "s/error_reporting = .*/error_reporting = E_ALL/" /etc/php/7.3/cli/php.ini
			sed -i "s/display_errors = .*/display_errors = On/" /etc/php/7.3/cli/php.ini
			sed -i "s/memory_limit = .*/memory_limit = 512M/" /etc/php/7.3/cli/php.ini
			sed -i "s/;date.timezone.*/date.timezone = ${DEFAULT_TIMEZONE//\//\\/}/" /etc/php/7.3/cli/php.ini

			# Disable xdebug on CLI
			if [ "$DISABLE_XDEBUG_ON_CLI" == "y" ]; then
				phpdismod -s cli xdebug
			fi
			setAsInstalled "php7.3"

			if [ "$INSTALL_SERVICE_PHPFPM" == "y" ]; then
				installFPM "7.3"
			fi

			if [ "$INSTALL_DB_SERVERS" == "y" ] && [ "$INSTALL_SERVICE_MONGOD" == "y" ]; then
				installMongo "7.3"
			fi
		fi
	fi

	if [ "$INSTALL_PHP_74" == "y" ]; then
		echoBanner "PHP 7.4"
		checkIfInstalled "php7.4" "PHP 7.4"
		if [ "$?" == "0" ]; then
			apt-get $APT_SILENCE install -y --allow-downgrades --allow-remove-essential --allow-change-held-packages \
			php7.4-cli php7.4-cgi php7.4-dev php7.4-pgsql php7.4-sqlite3 php7.4-gd php7.4-curl php7.4-imap php7.4-mysql php7.4-common \
			php7.4-mbstring php7.4-xml php7.4-zip php7.4-bcmath php7.4-soap php7.4-intl php7.4-readline php7.4-ldap php7.4-dev \
			php-xdebug php-memcached php-pear php-apcu php-amqp

			sed -i "s/error_reporting = .*/error_reporting = E_ALL/" /etc/php/7.4/cli/php.ini
			sed -i "s/display_errors = .*/display_errors = On/" /etc/php/7.4/cli/php.ini
			sed -i "s/memory_limit = .*/memory_limit = 512M/" /etc/php/7.4/cli/php.ini
			sed -i "s/;date.timezone.*/date.timezone = ${DEFAULT_TIMEZONE//\//\\/}/" /etc/php/7.4/cli/php.ini

			# Disable xdebug on CLI
			if [ "$DISABLE_XDEBUG_ON_CLI" == "y" ]; then
				phpdismod -s cli xdebug
			fi
			setAsInstalled "php7.4"

			if [ "$INSTALL_SERVICE_PHPFPM" == "y" ]; then
				installFPM "7.4"
			fi

			if [ "$INSTALL_DB_SERVERS" == "y" ] && [ "$INSTALL_SERVICE_MONGOD" == "y" ]; then
				installMongo "7.4"
			fi
		fi
	fi

	update-alternatives --set php /usr/bin/php$DEFAULT_PHP_VERSION
	update-alternatives --set php-config /usr/bin/php-config$DEFAULT_PHP_VERSION
	update-alternatives --set phpize /usr/bin/phpize$DEFAULT_PHP_VERSION

	#
	# Blackfire
	if [ "$INSTALL_SERVICE_BLACKFIRE" == "y" ]; then
		echoBanner "PHP - blackfire"
		checkIfInstalled "php-blackfire" "PHP - blackfire"
		if [ "$?" == "0" ]; then
			apt-get $APT_SILENCE install -y blackfire-agent blackfire-php
			addToMemoire "Blackfire needs more love. (https://blackfire.io/my/settings/credentials)"

			autorunService "blackfire" "blackfire-agent" "blackfire"
			setAsInstalled "php-blackfire"
		fi
	fi

	#
	# Composer
	echoBanner "PHP - composer"
	checkIfInstalled "php-composer" "PHP - composer"
	if [ "$?" == "0" ]; then
		curl -sS https://getcomposer.org/installer | php
		mv composer.phar $WSLDP_GLOBAL_BIN_DIR/composer
		mkdir $COMPOSER_GLOBAL_DIR 2> /dev/null
		chown -R $INSTALLED_FOR_USER:$INSTALLED_FOR_USER $COMPOSER_GLOBAL_DIR 2> /dev/null
		chown -R $INSTALLED_AS_USER:$INSTALLED_AS_USER $INSTALLED_AS_HOME/.composer 2> /dev/null
		# Add Composer vendor/bin directory to PATH
		getTimestamp
		cp ./resources/profile.d/profile_d_composer.sh ./resources/profile.d/profile_d_composer.$DATE_NOW.sh
		sed -i "s/COMPOSER_GLOBAL_DIR/${COMPOSER_GLOBAL_DIR//\//\\/}/" ./resources/profile.d/profile_d_composer.$DATE_NOW.sh
		cp ./resources/profile.d/profile_d_composer.$DATE_NOW.sh /etc/profile.d/composer.sh 2> /dev/null
		rm ./resources/profile.d/profile_d_composer.$DATE_NOW.sh 2> /dev/null

		setAsInstalled "php-composer"
	fi

	# install aliases
	installAliases ./resources/shell/bash_aliases_php
fi
