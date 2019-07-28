#!/bin/bash

#
# Elasticsearch
if [ "$INSTALL_DB_SERVERS" == "y" ] && [ "$INSTALL_SERVICE_ELASTICSEARCH" == "y" ]; then
	echoBanner "DB Elasticsearch"

	if [ "$RUNNING_ON" == "wsl" ]; then
		echoError "WSLDP - Elasticsearch is not supported on WSL v1"
	else
		checkIfInstalled "db-elasticsearch" "DB Elasticsearch"
		if [ "$?" == "0" ]; then
			export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
			apt-get $APT_SILENCE install -y openjdk-11-jre elasticsearch
			# Update configuration to use 'default_cluster' as the cluster
			sed -i "s/#cluster.name: my-application/cluster.name: default_cluster/" /etc/elasticsearch/elasticsearch.yml

			autorunService "elasticsearch"
			setAsInstalled "db-elasticsearch"
		fi
	fi
fi
