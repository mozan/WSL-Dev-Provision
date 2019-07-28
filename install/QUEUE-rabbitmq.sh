#!/bin/bash

#
# RabbitMQ
if [ "$INSTALL_QUEUE_SERVERS" == "y" ] && [ "$INSTALL_SERVICE_RABBITMQ" == "y" ]; then
	echoBanner "QUEUE - rabbitmq"
	checkIfInstalled "queue-rabbitmq" "QUEUE - rabbitmq"
	if [ "$?" == "0" ]; then
		apt-get $APT_SILENCE install -y rabbitmq-server --fix-missing

# TODO - running via /etc/init.d/autorun still fails, even with this sed
#		sed -i "s/exit/#exit/" /etc/init.d/rabbitmq-server

		autorunService "rabbitmq-server.service" "rabbitmq-server" "rabbitmq"
		setAsInstalled "queue-rabbitmq"
	fi
fi
