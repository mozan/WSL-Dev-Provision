#!/bin/bash

#
# PowerShell CLI
if [ "$INSTALL_CLI_POWERSHELL" == "y" ]; then
	echoBanner "CLI - Powershell"
	checkIfInstalled "cli-powershell" "CLI - Powershell"
	if [ "$?" == "0" ]; then
		apt-get $APT_SILENCE install -y powershell
		setAsInstalled "cli-powershell"
	fi
fi
