#!/bin/bash

# !IMPORTANT! If running on WSL - your instance name - should be unique across all 
# your WSL installs (use only chars, numbers and "_-" symbols)
export INSTANCE_NAME=ubuntu18_04

#
# Are we running on WSL, WSL2 or native? (wsl, wsl2, native)
# TODO - determine on what kind of system are we running
export RUNNING_ON=native
if [ "$RUNNING_ON" == "wsl" ]; then
	# use LD_PRELOAD for:
	# getsockopt() - TCP_INFO
	# setsockopt() - TCP_DEFER_ACCEPT
	export USE_LD_PRELOAD_SOCKOPT=y

	# link to /mnt/c/Users/my_windows_username/
	export WINHOME=winhome

	# Self update directory
	# Not needed, but very usefull (./self-update.sh will not work if the final SELF_UPDATE_DIR do not resolve)
	export SELF_UPDATE_DIR=../$WINHOME/Projects/Tools/WSL-Dev-Provision

	# c:\ mountpoint
	export C_MOUNTPOINT=/mnt/c

	# Where is nircmdc.exe file located (used to elevate privileges on windows host to auto edit hosts file - https://www.nirsoft.net/utils/nircmd.html)
	export NIRCMDC_EXE=$C_MOUNTPOINT/tools/bin/nircmdc.exe

	# hosts file
	export HOSTS_FILE="$C_MOUNTPOINT/Windows/System32/drivers/etc/hosts"
else
	# hosts file
	export HOSTS_FILE=/etc/hosts
fi

#
# Should the install script install everything as global (not user specific)? Better option = y
export WSL_INSTALL_AS_GLOBAL=y

#
# WSL-Dev-Provision global directories (if used)
if [ "$WSL_INSTALL_AS_GLOBAL" == "y" ]; then
#	export INSTALLED_FOR_USER=vagrant
	# WSL-Dev-Provision global config dir
	export WSLDP_GLOBAL_CONFIG_DIR=/etc/wsldp
	# WSL-Dev-Provision global dir
	export WSLDP_GLOBAL_DIR=/usr/local
	# WSL-Dev-Provision bin dir
	export WSLDP_GLOBAL_BIN_DIR=$WSLDP_GLOBAL_DIR/bin
	# WSL-Dev-Provision lib dir
	export WSLDP_GLOBAL_LIB_DIR=$WSLDP_GLOBAL_DIR/lib
else
	# install locally for defined user. If empty, current user will be used
	export INSTALLED_FOR_USER=vagrant
	# WSL-Dev-Provision global config dir (will be prefixed by INSTALLED_FOR_USER home dir)
	export WSLDP_USER_GLOBAL_CONFIG_DIR=.wsldp
	# WSL-Dev-Provision global dir (will be prefixed by INSTALLED_FOR_USER home dir)
	export WSLDP_USER_GLOBAL_DIR=.local
	# WSL-Dev-Provision bin dir (will be prefixed by INSTALLED_FOR_USER home dir)
	export WSLDP_USER_GLOBAL_BIN_DIR=$WSLDP_USER_GLOBAL_DIR/bin
	# WSL-Dev-Provision lib dir (will be prefixed by INSTALLED_FOR_USER home dir)
	export WSLDP_USER_GLOBAL_LIB_DIR=$WSLDP_USER_GLOBAL_DIR/lib
fi

#
# per man apt - empty or -q or -qq
export APT_SILENCE=-qq

#
# system
export LOCALE=C.UTF-8
export DEFAULT_TIMEZONE=Europe/Warsaw
export LOCAL_IP_ADDRESS=192.168.1.10
export LOCAL_NET=192.168.1.0
export LOCAL_NET_MASK=24
export UPGRADE_SYSTEM_PACKAGES=y

#
# db related
export DB_HOST=192.168.x.x
export DB_ADMIN_USERNAME=user
export DB_PASSWORD=pass

#
# apps / clients
##########################################################
export INSTALL_NGROK=n
if [ "$INSTALL_NGROK" == "y" ]; then
	export NGROK_PORT=4040
fi
export INSTALL_FLYWAY=n

#
# CLI related (heroku, powershell, cloud related)
##########################################################
export INSTALL_CLI_TOOLS=y
if [ "$INSTALL_CLI_TOOLS" == "y" ]; then
	# heroku
	export INSTALL_CLI_HEROKU=n

	# ZSH / oh_my_zsh
	export INSTALL_CLI_ZSH=y

	export INSTALL_CLI_POWERSHELL=y
	if [ "$INSTALL_CLI_POWERSHELL" == "y" ]; then
		export PPA_MICROSOFT=y
	fi

	# Cloud related CLIs (AWS / Google / Microsoft)
	export CLOUD=y
	if [ "$CLOUD" == "y" ]; then
		# AWS
		export INSTALL_CLI_AWS=y
		if [ "$INSTALL_CLI_AWS" == "y" ]; then
			export PPA_AMAZON=y
		fi
		# Google
		export INSTALL_CLI_GOOGLE_CLOUD_SDK=y
		if [ "$INSTALL_CLI_GOOGLE_CLOUD_SDK" == "y" ]; then
			export PPA_GOOGLE=y
		fi
		# Microsoft
		export INSTALL_CLI_AZURE=y
		if [ "$INSTALL_CLI_AZURE" == "y" ]; then
			export PPA_MICROSOFT=y
		fi
	fi
fi

#
# DB servers
##########################################################
export INSTALL_DB_SERVERS=y
if [ "$INSTALL_DB_SERVERS" = "y" ]; then
	export INSTALL_SERVICE_ELASTICSEARCH=n
	export INSTALL_SERVICE_MONGOD=y
	export INSTALL_SERVICE_MYSQL=y
	export INSTALL_SERVICE_NEO4J=n
	export INSTALL_SERVICE_POSTGRESQL=n
	export INSTALL_SQLITE3=n

	# memory
	export INSTALL_SERVICE_MEMCACHED=y
	export INSTALL_SERVICE_REDIS=y
fi

#
# Languages
##########################################################

# GO lang
export INSTALL_GOLANG=n

# Java JRE/JDK
export INSTALL_JRE=y
export INSTALL_JDK=n

# Microsoft related
export PPA_MICROSOFT=y

# NODEJS
export INSTALL_NODEJS=y

# PHP
export INSTALL_PHP=y
if [ "$INSTALL_PHP" == "y" ]; then
	export INSTALL_PHP_56=y
	export INSTALL_PHP_70=n
	export INSTALL_PHP_71=n
	export INSTALL_PHP_72=n
	export INSTALL_PHP_73=y
	export INSTALL_PHP_74=y
	export INSTALL_SERVICE_PHPFPM=y

	export DEFAULT_PHP_VERSION=7.4

	DPV="${DEFAULT_PHP_VERSION//.}"

	PHP_VERSION_EXPECTED=false

	# Script name that run this file
	INVOKING_SCRIPT=`basename "$0"`
	if [ "$INVOKING_SCRIPT" != "self-update.sh" ]; then
		if [ "$INSTALL_PHP_56" == "y" ] && [ "$DPV" == "56" ]; then
			PHP_VERSION_EXPECTED=true
		fi
		if [ "$INSTALL_PHP_70" == "y" ] && [ "$DPV" == "70" ]; then
			PHP_VERSION_EXPECTED=true
		fi
		if [ "$INSTALL_PHP_71" == "y" ] && [ "$DPV" == "71" ]; then
			PHP_VERSION_EXPECTED=true
		fi
		if [ "$INSTALL_PHP_72" == "y" ] && [ "$DPV" == "72" ]; then
			PHP_VERSION_EXPECTED=true
		fi
		if [ "$INSTALL_PHP_73" == "y" ] && [ "$DPV" == "73" ]; then
			PHP_VERSION_EXPECTED=true
		fi
		if [ "$INSTALL_PHP_74" == "y" ] && [ "$DPV" == "74" ]; then
			PHP_VERSION_EXPECTED=true
		fi
		if [ $PHP_VERSION_EXPECTED != "true" ]; then
			echo "Default PHP version is not on the install list ($DEFAULT_PHP_VERSION). Checkout params.sh file (DEFAULT_PHP_VERSION)"
			exit
		fi
	fi

	export DISABLE_XDEBUG_ON_CLI=y
	export AUTOSTART_PHPFPM=n

	export INSTALL_SERVICE_BLACKFIRE=y

	export COMPOSER_GLOBAL_DIR=/usr/local/lib/composer

	# PHP misc devel apps
	export INSTALL_PHP_MISC_DEVEL=y
	if [ "$INSTALL_PHP_MISC_DEVEL" == "y" ]; then
		export INSTALL_BEHAT=y
		export INSTALL_LARAVEL_COMMANDS=y
		export INSTALL_PHING=y
		export INSTALL_PHP_CODESNIFFER=y
		export INSTALL_PHPDOC=y
		export INSTALL_PHPINSIGHTS=y
		export INSTALL_PHPSPEC=y
		export INSTALL_PHPSTAN=y
		export INSTALL_PHPUNIT=y
	fi

	export INSTALL_SYMFONY_COMMAND=y

	# apps
	export INSTALL_DRUSH_CONSOLE_LAUNCHER=n
	export INSTALL_DRUPAL_CONSOLE_LAUNCHER=n
	export INSTALL_WP_CLI=y
fi

# Python
export INSTALL_PYTHON=y

# Ruby
export INSTALL_RUBY=n

#
# Mail related
##########################################################
export INSTALL_SERVICE_MAILHOG=y
export INSTALL_SERVICE_POSTFIX=y
if [ "$INSTALL_SERVICE_POSTFIX" == "y" ]; then
	export POSTFIX_DOMAIN=local.domain
fi

#
# Misc servers
##########################################################
export INSTALL_SERVICE_OPENSSH=y

#
# Queue servers
##########################################################
export INSTALL_QUEUE_SERVERS=y
if [ "$INSTALL_QUEUE_SERVERS" = "y" ]; then
	export INSTALL_SERVICE_BEANSTALKD=y
	export INSTALL_SERVICE_RABBITMQ=y
fi

#
# Shells related
##########################################################
export ADD_ALIASES=y
export ADD_ALIASES_TO_ROOT_ACCOUNT=y

#
# Web driver
##########################################################
export WEB_DRIVER=y

#
# WWW servers
##########################################################
export INSTALL_WWW_SERVERS=n
if [ "$INSTALL_WWW_SERVERS" = "y" ]; then
	export INSTALL_SERVICE_APACHE2=y
	export INSTALL_SERVICE_NGINX=y

	# Admin websites (phpMyAdmin, Redis, opcache, etc)
	export INSTALL_ADMIN_WEBSITES=y
	if [ "$INSTALL_ADMIN_WEBSITES" == "y" ]; then
		export ADMIN_WEBSITE_ROOTDIR=/var/www/admin
		export ADMIN_WEBSITE_SITENAME=admin.local
		export ADMIN_WEBSITE_ADD_TO_HOSTS=true
	fi
fi

#
# XWindows related
##########################################################
export INSTALL_X=n
if [ "$INSTALL_X" == "y" ]; then
	export INSTALL_XFCE4=y
	export INSTALL_TERMINATOR=y
fi

##########################################################
## No need to change anything below
##########################################################

# WSL-Dev-Provision source bin dir
export WSLDP_GLOBAL_SOURCE_BIN_DIR=./resources/bin/

# Store any reminders to display at the end. (Will be prefixed with a directory. This is just a file name)
export MEMOIRE_FILE=MEMOIRE

#
# Your local params...
##########################################################
source params_local.sh 2> /dev/null
