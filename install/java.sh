#!/bin/bash

#
# Java runtime
if [ "$INSTALL_JRE" == "y" ]; then
	echoBanner "JRE"
	checkIfInstalled "jre" "JRE"
	if [ "$?" == "0" ]; then
		apt-get $APT_SILENCE install -y openjdk-11-jre
		setAsInstalled "jre"
	fi
fi

#
# Java SDK
if [ "$INSTALL_JDK" == "y" ]; then
	echoBanner "JDK"
	checkIfInstalled "jdk" "JDK"
	if [ "$?" == "0" ]; then
		apt-get $APT_SILENCE install -y openjdk-11-jdk
		setAsInstalled "jdk"
	fi
fi
