#!/bin/bash

source ./_init.sh

echoBanner "additional packages" "Configuring"
if [ "$PPA_GOOGLE" == "y" ]; then
	echo "- Google packages..."
	checkIfInstalled "ppa-google" "Google packages"
	if [ "$?" == "0" ]; then
		# Add the Cloud SDK distribution URI as a package source
		echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] http://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
		# Import the Google Cloud Platform public key
		curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -
		setAsInstalled "ppa-google"
	fi
fi

if [ "$PPA_MICROSOFT" == "y" ]; then
	echo "- Microsoft packages..."
	checkIfInstalled "ppa-microsoft" "Microsoft packages"
	if [ "$?" == "0" ]; then
		curl -sL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | tee /etc/apt/trusted.gpg.d/microsoft.asc.gpg > /dev/null
		export AZ_REPO=$(lsb_release -cs)
		echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ $AZ_REPO main" > /etc/apt/sources.list.d/azure-cli.list
		wget -q https://packages.microsoft.com/config/ubuntu/18.04/packages-microsoft-prod.deb
		dpkg -i packages-microsoft-prod.deb > /dev/null
		rm packages-microsoft-prod.deb 2> /dev/null
		setAsInstalled "ppa-microsoft"
	fi
fi

if [ "$INSTALL_DB_SERVERS" == "y" ]; then
	if [ "$INSTALL_SERVICE_ELASTICSEARCH" == "y" ]; then
		echo "- Elasticsearch packages..."
		checkIfInstalled "ppa-db-elasticsearch" "Elasticsearch packages"
		if [ "$?" == "0" ]; then
			wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | apt-key add -
			echo "deb https://artifacts.elastic.co/packages/6.x/apt stable main" > /etc/apt/sources.list.d/elastic-6.x.list
			setAsInstalled "ppa-db-elasticsearch"
		fi
	fi

	if [ "$INSTALL_SERVICE_MONGOD" == "y" ]; then
		echo "- Mongod packages..."
		checkIfInstalled "ppa-db-mongod" "Mongod packages"
		if [ "$?" == "0" ]; then
			apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 9DA31620334BD75D9DCB49F368818C72E52529D4 > /dev/null 2>&1
			echo "deb [ arch=amd64 ] https://repo.mongodb.org/apt/ubuntu bionic/mongodb-org/4.0 multiverse" > /etc/apt/sources.list.d/mongodb-org-4.0.list
			setAsInstalled "ppa-db-mongod"
		fi
	fi

	if [ "$INSTALL_SERVICE_NEO4J" == "y" ]; then
		echo "- Neo4j packages..."
		checkIfInstalled "ppa-db-neo4j" "Neo4j packages"
		if [ "$?" == "0" ]; then
			wget -O - https://debian.neo4j.com/neotechnology.gpg.key | sudo apt-key add -
			echo 'deb https://debian.neo4j.com stable latest' | sudo tee /etc/apt/sources.list.d/neo4j.list
			# wget -qO - https://debian.neo4j.org/neotechnology.gpg.key | apt-key add -
			# echo 'deb https://debian.neo4j.org/repo stable/' >> /etc/apt/sources.list.d/neo4j.list
			setAsInstalled "ppa-db-neo4j"
		fi
	fi

	if [ "$INSTALL_SERVICE_RABBITMQ" == "y" ]; then
		echo "- RabbitMQ packages..."
		checkIfInstalled "ppa-db-rabbitmq" "RabbitMQ packages"
		echo "deb https://dl.bintray.com/rabbitmq-erlang/debian bionic erlang" > /etc/apt/sources.list.d/bintray.erlang.list
		echo "deb https://dl.bintray.com/rabbitmq/debian bionic main" > /etc/apt/sources.list.d/bintray.rabbitmq.list
		apt-key adv --keyserver "hkps.pool.sks-keyservers.net" --recv-keys "0x6B73A36E6026DFCA" > /dev/null 2>&1
		setAsInstalled "ppa-db-rabbitmq"
	fi
fi

# if [ "$INSTALL_SERVICE_NGINX" == "y" ]; then
# 	echo "- NGINX packages..."
# 	checkIfInstalled "ppa-www-nginx" "NGINX packages"
# 	if [ "$?" == "0" ]; then
# 		apt-add-repository ppa:nginx/development -y > /dev/null 2>&1
# 		setAsInstalled "ppa-www-nginx"
# 	fi
# fi

if [ "$INSTALL_NODEJS" == "y" ]; then
	echo "- NODEJS packages..."
	checkIfInstalled "ppa-nodejs" "NODEJS packages"
	if [ "$?" == "0" ]; then
		curl -sL https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
		echo "deb https://dl.yarnpkg.com/debian/ stable main" > /etc/apt/sources.list.d/yarn.list

		curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
		echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list

		setAsInstalled "ppa-nodejs"
	fi
fi

if [ "$INSTALL_PHP" == "y" ]; then
	echo "- PHP packages..."
	checkIfInstalled "ppa-php" "PHP packages"
	if [ "$?" == "0" ]; then
		apt-add-repository ppa:ondrej/php -y > /dev/null 2>&1
		if [ "$INSTALL_SERVICE_BLACKFIRE" == "y" ]; then
			echo "- PHP blackfire packages..."
			checkIfInstalled "ppa-php-blackfire" "BLACKFIRE packages"
			if [ "$?" == "0" ]; then
				wget -q -O - https://packages.blackfire.io/gpg.key | apt-key add -
				echo "deb http://packages.blackfire.io/debian any main" > /etc/apt/sources.list.d/blackfire.list
				setAsInstalled "ppa-php-blackfire"
			fi
		fi
		setAsInstalled "ppa-php"
	fi
fi

apt-get $APT_SILENCE -y update
add-apt-repository universe > /dev/null
