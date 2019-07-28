#!/bin/bash

#
# OpenSSH server
if [ "$INSTALL_SERVICE_OPENSSH" == "y" ]; then
	echoBanner "OpenSSH Server"
	checkIfInstalled "openssh-server" "OpenSSH Server"
	if [ "$?" == "0" ]; then
		apt purge -y openssh-server
		apt install openssh-server

		ssh-keygen -A

		cp ./resources/config/sshd_config ./resources/config/_tmp_sshd_config
		echo "AllowUsers $INSTALLED_AS_USER" >> ./resources/config/_tmp_sshd_config

		# now=`date '+%Y_%m_%d__%H_%M_%S'`
		getTimestamp
		mv /etc/ssh/sshd_config /etc/ssh/sshd_config.$DATE_NOW
		mv ./resources/config/_tmp_sshd_config /etc/ssh/sshd_config

		installAliases ./resources/shell/bash_aliases_openssh

		autorunService "openssh" "ssh" "openssh"
		setAsInstalled "openssh-server"
	fi
fi
