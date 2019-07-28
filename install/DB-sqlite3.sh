#!/bin/bash

#
# SQLite3
if [ "$INSTALL_DB_SERVERS" == "y" ] && [ "$INSTALL_SQLITE3" == "y" ]; then
	echoBanner "DB - SQLITE3"
	checkIfInstalled "db-sqlite3" "DB - SQLITE3"
	if [ "$?" == "0" ]; then
		apt-get $APT_SILENCE install -y sqlite3 libsqlite3-dev
		setAsInstalled "db-sqlite3"
	fi
fi
