#!/bin/bash

export WSLDP_GLOBAL_CONFIG_DIR=$1

source ./_init.sh

#
# Init MEMOIRE file
createMemoireFile

#
# Aliases
installAliases ./resources/shell/bash_aliases

#
# Main work
./_worker_install.sh

#
# Local (private) work
./worker_local.sh

#
# All around clean up
./_worker_cleanup.sh

#
# Finalize aliases
finalizeAliases

#
# Check if $INSTALLED_FOR_USER account has been created. If yes - ask for a new password
if [ "$ASK_FOR_INSTALLED_FOR_USER_PASSWORD" == "y" ]; then
	echoBanner "$INSTALLED_FOR_USER" "Set password for: "
	passwd $INSTALLED_FOR_USER
fi

#
# Add $INSTALLED_FOR_USER user to wWW-data
if [ "$INSTALL_WWW_SERVERS" = "y" ]; then
	usermod -a -G www-data $INSTALLED_FOR_USER
	echo " "
fi

#
# Display MEMOIRE file
if [ -f $WSLDP_GLOBAL_CONFIG_DIR/$MEMOIRE_FILE ]; then
	echoInfo "Do not forget about:"
	showMemoireFile
fi
