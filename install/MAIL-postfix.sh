#!/bin/bash

#
# Postfix
if [ "$INSTALL_SERVICE_POSTFIX" == "y" ]; then
	echoBanner "MAIL - postfix"
	checkIfInstalled "mail-postfix" "MAIL - postfix"
	if [ "$?" == "0" ]; then
		echo "postfix postfix/mailname string $POSTFIX_DOMAIN" | debconf-set-selections
		echo "postfix postfix/main_mailer_type string 'Internet Site'" | debconf-set-selections
		apt-get $APT_SILENCE install -y postfix

		if [ "$INSTALL_MAILHOG" == "y" ]; then
			sed -i "s/relayhost =/relayhost = [localhost]:1025/g" /etc/postfix/main.cf
		fi

		addToMemoire "Postfix needs more affection - (/etc/postfix)."

		autorunService "postfix"
		setAsInstalled "mail-postfix"
	fi
fi
