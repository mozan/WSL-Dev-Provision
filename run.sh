#!/bin/bash

source ./params.sh
source ./_functions.sh

export INSTALLED_AS_USER=$(id -nu)
export INSTALLED_AS_HOME=$(cat /etc/passwd | grep "$INSTALLED_AS_USER" | cut -d":" -f6)

if [ "$INSTALLED_FOR_USER" == "" ]; then
	export INSTALLED_FOR_USER=$INSTALLED_AS_USER
fi

#
# Initialize the INSTALLED_FOR_* variables
checkIfInstalledForEqualsInstalledAs
if [ "$?" == "0" ]; then
	export INSTALLED_FOR_USER=$INSTALLED_AS_USER
else
	# Check for $INSTALLED_FOR_USER user
	if id "$INSTALLED_FOR_USER" >/dev/null 2>&1; then
		echo "User $INSTALLED_FOR_USER exists. Skipping adduser..."
	else
		sudo adduser --disabled-password --gecos "" $INSTALLED_FOR_USER
		ASK_FOR_INSTALLED_FOR_USER_PASSWORD=y
	fi
fi
export INSTALLED_FOR_HOME=$(cat /etc/passwd | grep "$INSTALLED_FOR_USER" | cut -d":" -f6)

#
# Initialize the WSLDP_GLOBAL_* variables while not installed as global
if [ "$WSL_INSTALL_AS_GLOBAL" != "y" ]; then
	export WSLDP_GLOBAL_CONFIG_DIR=$INSTALLED_FOR_HOME/$WSLDP_USER_GLOBAL_CONFIG_DIR
	export WSLDP_GLOBAL_DIR=$INSTALLED_FOR_HOME/$WSLDP_USER_GLOBAL_DIR
	export WSLDP_GLOBAL_BIN_DIR=$INSTALLED_FOR_HOME/$WSLDP_USER_GLOBAL_BIN_DIR
	export WSLDP_GLOBAL_LIB_DIR=$INSTALLED_FOR_HOME/$WSLDP_USER_GLOBAL_LIB_DIR
fi

#
# Init WSLDP Dev global dir
initWSLDPGlobalDir

#
# Just do it...
sudo ./_worker_install_init.sh $WSLDP_GLOBAL_CONFIG_DIR

echoInfo "Done. Relog..."
echo " "
