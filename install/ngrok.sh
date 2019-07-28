#!/bin/bash

#
# ngrok
if [ "$INSTALL_NGROK" == "y" ]; then
	echoBanner "NGROK"
	checkIfInstalled "ngrok" "NGROK"
	if [ "$?" == "0" ]; then
		curl -sL https://bin.equinox.io/c/4VmDzA7iaHb/ngrok-stable-linux-amd64.zip --output ngrok-stable-linux-amd64.zip
		unzip ngrok-stable-linux-amd64.zip -d $WSLDP_GLOBAL_BIN_DIR
		rm -rf ngrok-stable-linux-amd64.zip

		PATH_NGROK="$INSTALLED_FOR_HOME/.ngrok2"
		PATH_CONFIG="${PATH_NGROK}/ngrok.yml"

		if [ ! -f $PATH_CONFIG ]; then
			mkdir -p $PATH_NGROK && echo "web_addr: $LOCAL_IP_ADDRESS:$NGROK_PORT" > $PATH_CONFIG
		fi

		installAliases ./resources/shell/bash_aliases_ngrok

		setAsInstalled "ngrok"
	fi
fi
