#!/bin/bash

#
# Azure CLI
if [ "$INSTALL_CLI_AZURE" == "y" ]; then
	echoBanner "CLI - Azure"
	checkIfInstalled "cli-azure" "CLI - Azure"
	if [ "$?" == "0" ]; then
		apt-get $APT_SILENCE install -y azure-cli
		addToMemoire "Microsoft Azure stuff. Init via 'az login'"
		setAsInstalled "cli-azure"
	fi
fi
