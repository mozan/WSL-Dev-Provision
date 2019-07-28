#!/bin/bash

#
# Memcached
if [ "$INSTALL_DB_SERVERS" == "y" ] && [ "$INSTALL_SERVICE_MEMCACHED" == "y" ]; then
	echoBanner "DB - memcached"
	checkIfInstalled "db-memcached" "DB - memcached"
	if [ "$?" == "0" ]; then
		apt-get $APT_SILENCE install -y memcached

		autorunService "memcached.service"
		setAsInstalled "db-memcached"
	fi
fi
