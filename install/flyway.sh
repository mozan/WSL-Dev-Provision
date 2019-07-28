#!/bin/bash

#
# Flyway
if [ "$INSTALL_FLYWAY" == "y" ]; then
	echoBanner "FLYWAY"
	checkIfInstalled "flyway" "FLYWAY"
	if [ "$?" == "0" ]; then
		curl -sL https://repo1.maven.org/maven2/org/flywaydb/flyway-commandline/4.2.0/flyway-commandline-4.2.0-linux-x64.tar.gz --output flyway-commandline-4.2.0-linux-x64.tar.gz
		tar -zxvf flyway-commandline-4.2.0-linux-x64.tar.gz -C $WSLDP_GLOBAL_DIR > /dev/null
		chmod +x $WSLDP_GLOBAL_DIR/flyway-4.2.0/flyway
		ln -s $WSLDP_GLOBAL_DIR/flyway-4.2.0/flyway $WSLDP_GLOBAL_BIN_DIR/flyway
		rm -rf flyway-commandline-4.2.0-linux-x64.tar.gz
		setAsInstalled "flyway"
	fi
fi
