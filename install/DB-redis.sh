#!/bin/bash

#
# Redis
if [ "$INSTALL_DB_SERVERS" == "y" ] && [ "$INSTALL_SERVICE_REDIS" == "y" ]; then
	echoBanner "DB - redis"
	checkIfInstalled "db-redis" "DB - redis"
	if [ "$?" == "0" ]; then
		apt-get $APT_SILENCE install -y redis-server

		autorunService "redis-server.service" "redis-server" "redis"
		setAsInstalled "db-redis"
	fi
fi
