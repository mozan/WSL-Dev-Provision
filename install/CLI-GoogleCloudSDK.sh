#!/bin/bash

#
# Google cloud SDK CLI
if [ "$INSTALL_CLI_GOOGLE_CLOUD_SDK" == "y" ]; then
	echoBanner "CLI - Google Cloud SDK"
	checkIfInstalled "cli-google-cloud-sdk" "CLI - Google Cloud SDK"
	if [ "$?" == "0" ]; then
		apt-get $APT_SILENCE install -y google-cloud-sdk
		addToMemoire "Google cloud stuff. Init via 'gcloud init'"
		setAsInstalled "cli-google-cloud-sdk"
	fi
fi

# optional
	# google-cloud-sdk-app-engine-python
	# google-cloud-sdk-app-engine-python-extras
	# google-cloud-sdk-app-engine-java
	# google-cloud-sdk-app-engine-go
	# google-cloud-sdk-datalab
	# google-cloud-sdk-datastore-emulator
	# google-cloud-sdk-pubsub-emulator
	# google-cloud-sdk-cbt
	# google-cloud-sdk-cloud-build-local
	# google-cloud-sdk-bigtable-emulator
	# kubectl

# For example, the google-cloud-sdk-app-engine-java component can be installed as follows:
# apt-get install google-cloud-sdk-app-engine-java
