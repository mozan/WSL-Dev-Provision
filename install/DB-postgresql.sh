#!/bin/bash

#
# Please ignore the
# WARNING: could not flush dirty data: Function not implemented multiple times
# It's WSL related bug, should be corrected by PostgreSQL people
# (https://github.com/Microsoft/WSL/issues/3863)
#

#
# Postgres
if [ "$INSTALL_DB_SERVERS" == "y" ] && [ "$INSTALL_SERVICE_POSTGRESQL" == "y" ]; then
	echoBanner "DB - PostgreSQL"

	if [ "$RUNNING_ON" == "wsl" ]; then
		echoError "WSLDP - PostgreSQL is not supported on WSL v1"
	else
		checkIfInstalled "db-postgresql" "DB - PostgreSQL"
		if [ "$?" == "0" ]; then
			apt-get $APT_SILENCE install -y postgresql-10

			# remote Access
			sed -i "s/#listen_addresses = 'localhost'/listen_addresses = '*'/g" /etc/postgresql/10/main/postgresql.conf
			# workaround for https://github.com/Microsoft/WSL/issues/3863
			echo "data_sync_retry = true" >> /etc/postgresql/10/main/postgresql.conf
			echo "host    all             all             $LOCAL_NET/$LOCAL_NET_MASK               md5" | tee -a /etc/postgresql/10/main/pg_hba.conf

			service postgresql start

			sudo -u postgres psql -c "CREATE ROLE $DB_ADMIN_USERNAME LOGIN PASSWORD '$DB_PASSWORD' SUPERUSER INHERIT NOCREATEDB NOCREATEROLE NOREPLICATION;"
			sudo -u postgres /usr/bin/createdb --echo --owner=$DB_ADMIN_USERNAME "$DB_ADMIN_USERNAME"_DB

			service postgresql stop

			autorunService "postgresql"
			setAsInstalled "db-postgresql"
		fi
	fi
fi
