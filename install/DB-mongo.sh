#!/bin/bash

# MongoD
if [ "$INSTALL_DB_SERVERS" == "y" ] && [ "$INSTALL_SERVICE_MONGOD" == "y" ]; then
	echoBanner "DB - Mongod"
	checkIfInstalled "db-mongod" "DB - Mongod"
	if [ "$?" == "0" ]; then
		apt-get $APT_SILENCE -o Dpkg::Options::="--force-confnew" install -y mongodb-org autoconf g++ make openssl libssl-dev libcurl4-openssl-dev pkg-config libsasl2-dev 
		sed -i "s/bindIp: .*/bindIp: 0.0.0.0/" /etc/mongod.conf

		cp ./resources/init.d/mongod-init /etc/init.d/mongod
		chmod +x /etc/init.d/mongod

		service mongod start
		mongo admin --eval "db.createUser({user:'$DB_ADMIN_USERNAME',pwd:'$DB_PASSWORD',roles:['root']})"
		service mongod stop

		autorunService "mongod"
		setAsInstalled "db-mongod"
	fi
fi
