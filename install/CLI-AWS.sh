#!/bin/bash

#
# AWS CLI
if [ "$INSTALL_CLI_AWS" == "y" ]; then
	echoBanner "CLI - AWS"
	checkIfInstalled "cli-aws" "CLI - AWS"
	if [ "$?" == "0" ]; then
		apt-get $APT_SILENCE install -y awscli
		addToMemoire "AWS CLI stuff. Init via 'aws configure'"
		setAsInstalled "cli-aws"
	fi
fi
