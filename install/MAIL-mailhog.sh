#!/bin/bash

#
# MailHog
if [ "$INSTALL_SERVICE_MAILHOG" == "y" ]; then
	echoBanner "MAIL - Mailhog"
	checkIfInstalled "mail-mailhog" "MAIL - Mailhog"
	if [ "$?" == "0" ]; then
		curl -sL https://github.com/mailhog/MailHog/releases/download/v1.0.0/MailHog_linux_amd64 --output $WSLDP_GLOBAL_BIN_DIR/mailhog
		chmod +x $WSLDP_GLOBAL_BIN_DIR/mailhog

		tee /etc/systemd/system/mailhog.service <<EOL
[Unit]
Description=Mailhog
After=network.target

[Service]
User=$INSTALLED_FOR_USER
ExecStart=$WSLDP_GLOBAL_BIN_DIR/mailhog > /dev/null 2>&1 &

[Install]
WantedBy=multi-user.target
EOL
# TODO jedna metoda na sprawdzenie jaki jest host
		if [[ "$(< /proc/version)" == *@(Microsoft|WSL)* ]]; then
			cp ./resources/init.d/mailhog-init /etc/init.d/mailhog
			sed -i "s|BIN=/usr/local/bin/mailhog.*|BIN=$WSLDP_GLOBAL_BIN_DIR/mailhog|" /etc/init.d/mailhog
			chmod a+x /etc/init.d/mailhog
		fi

		autorunService "mailhog"
		setAsInstalled "mail-mailhog"
	fi
fi
