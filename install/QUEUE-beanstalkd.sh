#!/bin/bash

#
# Beanstalk
if [ "$INSTALL_QUEUE_SERVERS" == "y" ] && [ "$INSTALL_SERVICE_BEANSTALKD" == "y" ]; then
	echoBanner "QUEUE - beanstalkd"
	checkIfInstalled "queue-beanstalkd" "QUEUE - beanstalkd"
	if [ "$?" == "0" ]; then
		apt-get $APT_SILENCE install -y beanstalkd
		sed -i "s/#START=yes/START=yes/" /etc/default/beanstalkd

		autorunService "beanstalkd.service"
		setAsInstalled "queue-beanstalkd"
	fi
fi
