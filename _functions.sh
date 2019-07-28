#!/bin/bash

#
# Echo related
##########################################################
echoBanner () {
	if [ -z "$2" ]; then
		KEYWORD=Installing
	else
		KEYWORD=$2
	fi

	echo " "
	echo -e '\E[37;44m' "$KEYWORD $1" '\033[0m'
	echo "--------------------------------------------------"
}

echoError () {
	echo " "
	echo -e '\E[0;31m' "$1" '\E[0m'
}

echoInfo () {
	echo " "
	echo -e '\E[37;44m' "$1" '\033[0m'
}

#
# WSLDP_GLOBAL_CONFIG_DIR related
##########################################################
createDefaultParamFiles () {
# TODO HOSTS_FILE ?
	bash -c "cat > ./.WSLDP_DEFAULTS << EOF
#!/bin/bash

export INSTALLED_AS_USER=$INSTALLED_AS_USER
export INSTALLED_AS_HOME=$INSTALLED_AS_HOME
export INSTALLED_FOR_USER=$INSTALLED_FOR_USER
export INSTALLED_FOR_HOME=$INSTALLED_FOR_HOME

export WSLDP_GLOBAL_CONFIG_DIR=$WSLDP_GLOBAL_CONFIG_DIR
export WSLDP_GLOBAL_DIR=$WSLDP_GLOBAL_DIR
export WSLDP_GLOBAL_BIN_DIR=$WSLDP_GLOBAL_BIN_DIR
export WSLDP_GLOBAL_LIB_DIR=$WSLDP_GLOBAL_LIB_DIR

export C_MOUNTPOINT=$C_MOUNTPOINT
export DEFAULT_PHP_VERSION=$DEFAULT_PHP_VERSION
export INSTANCE_NAME=$INSTANCE_NAME
export HOSTS_FILE=$HOSTS_FILE
export LOCAL_IP_ADDRESS=$LOCAL_IP_ADDRESS
export MEMOIRE_FILE=$MEMOIRE_FILE
export NIRCMDC_EXE=$C_MOUNTPOINT/tools/bin/nircmdc.exe
export RUNNING_ON=$RUNNING_ON
EOF
"
}

initWSLDPGlobalDir () {
	sudo mkdir $WSLDP_GLOBAL_CONFIG_DIR 2> /dev/null
	sudo mkdir $WSLDP_GLOBAL_CONFIG_DIR/installed 2> /dev/null
	sudo mkdir $WSLDP_GLOBAL_CONFIG_DIR/shell_aliases 2> /dev/null
	sudo mkdir $WSLDP_GLOBAL_DIR 2> /dev/null
	sudo mkdir $WSLDP_GLOBAL_BIN_DIR 2> /dev/null
	sudo mkdir $WSLDP_GLOBAL_LIB_DIR 2> /dev/null
	createDefaultParamFiles
	sudo mv ./.WSLDP_DEFAULTS $WSLDP_GLOBAL_CONFIG_DIR/defaults
}

setEnvWSLDPScriptsGlobals () {
	if [ "$1" == "WSLDP_GLOBAL_CONFIG_DIR" ]; then
		sed -i "s#$1=#$1=$2#" $3
	fi
}

#
# Memoires related
##########################################################
createMemoireFile () {
	MEMOIRE_DATE=$(date)
	echo $MEMOIRE_DATE >> $WSLDP_GLOBAL_CONFIG_DIR/$MEMOIRE_FILE
}

addToMemoire () {
	echo " - $1 $2 $3 $4 $5" >> $WSLDP_GLOBAL_CONFIG_DIR/$MEMOIRE_FILE
}

showMemoireFile () {
	cat $WSLDP_GLOBAL_CONFIG_DIR/$MEMOIRE_FILE 2> /dev/null
	echo -n
}

#
checkIfInstalledForEqualsInstalledAs () {
	if [ "$INSTALLED_FOR_USER" == "$INSTALLED_AS_USER" ]; then
        return "0"
    fi
    return "-1"
}

#
# aliases related
##########################################################
installAliases () {
	if [ "$ADD_ALIASES" == "y" ]; then
        cp $1 $WSLDP_GLOBAL_CONFIG_DIR/shell_aliases/ 2> /dev/null
	fi
}

finalizeAliases () {
	if [ "$ADD_ALIASES" == "y" ]; then
        CUR_DATE=$(date)
        # create backup of current aliases
        cp $INSTALLED_AS_HOME/.bash_aliases $INSTALLED_AS_HOME/.bash_aliases_$CUR_DATE 2> /dev/null
        if [ "$FOR_HOME" == "y" ]; then
            cp $INSTALLED_FOR_HOME/.bash_aliases $INSTALLED_FOR_HOME/.bash_aliases_$CUR_DATE 2> /dev/null
        fi
        if [ "$ADD_ALIASES_TO_ROOT_ACCOUNT" == "y" ]; then
            cp /root/.bash_aliases /root/.bash_aliases_$CUR_DATE 2> /dev/null
        fi

        # create the final alias file
        for f in `ls $WSLDP_GLOBAL_CONFIG_DIR/shell_aliases/* | sort -V`; do 
            cat $f >> $INSTALLED_AS_HOME/.bash_aliases
        done

		# sed final .bash_aliases
		sed -i "s#WSLDP_GLOBAL_CONFIG_DIR=#WSLDP_GLOBAL_CONFIG_DIR=$WSLDP_GLOBAL_CONFIG_DIR#" $INSTALLED_AS_HOME/.bash_aliases
		sed -i "s#-dxdebug.remote_host=_LOCAL_IP_ADDRESS_#-dxdebug.remote_host=$LOCAL_IP_ADDRESS#" $INSTALLED_AS_HOME/.bash_aliases

		chmod -x $INSTALLED_AS_HOME/.bash_aliases
		chown $INSTALLED_AS_USER:$INSTALLED_AS_USER $INSTALLED_AS_HOME/.bash_aliases

        # copy to INSTALLED_FOR and root if requested
        checkIfInstalledForEqualsInstalledAs
        if [ "$?" != "0" ]; then
            FOR_HOME="y"
        fi
        if [ "$FOR_HOME" == "y" ]; then
            cp $INSTALLED_AS_HOME/.bash_aliases $INSTALLED_FOR_HOME/.bash_aliases
            chmod -x $INSTALLED_FOR_HOME/.bash_aliases
            chown $INSTALLED_FOR_USER:$INSTALLED_FOR_USER $INSTALLED_FOR_HOME/.bash_aliases
        fi
        if [ "$ADD_ALIASES_TO_ROOT_ACCOUNT" == "y" ]; then
            cp $INSTALLED_AS_HOME/.bash_aliases /root/.bash_aliases
            chmod -x /root/.bash_aliases
            chown root:root /root/.bash_aliases
        fi
	fi
}

#
# Install related
##########################################################
# $2 == current as installed /etc/init.d/ start script
# $3 == requested /etc/init.d/ start script
autorunService () {
	service $1 enable > /dev/null 2>&1
	if [ "$2" != "" ] && [ "$3" != "" ]; then
		mv /etc/init.d/$2 /etc/init.d/$3 2> /dev/null
	fi
	systemctl enable $1 > /dev/null 2>&1
}

checkIfInstalled () {
	if [ "$WSL_INSTALL_AS_GLOBAL" == "y" ]; then
		if [ -f $WSLDP_GLOBAL_CONFIG_DIR/installed/$1 ]; then
		    echo "$2 already installed."
		    return "-1"
	    fi
	    return "0"
    else
		if [ -f $INSTALLED_FOR_HOME/.wsldp/installed/$1 ]; then
		    echo "$2 already installed."
		    return "-1"
		fi
		return "0"
    fi
}

setAsInstalled () {
	if [ "$WSL_INSTALL_AS_GLOBAL" == "y" ]; then
		touch $WSLDP_GLOBAL_CONFIG_DIR/installed/$1
	else
		touch $INSTALLED_FOR_HOME/.wsldp/installed/$1
	fi
}

#
# Miscs
##########################################################
composerInstall () {
	sudo su $INSTALLED_FOR_USER <<EOF
$WSLDP_GLOBAL_BIN_DIR/composer global require $1 -d $COMPOSER_GLOBAL_DIR
EOF
}

getTimestamp () {
	export DATE_NOW=`date '+%Y_%m_%d__%H_%M_%S'`
}

restartPHPFPM () {
	if [ "$AUTOSTART_PHPFPM" == "y" ] && [ "$DEFAULT_PHP_VERSION" == "$1" ]; then
		service php$DEFAULT_PHP_VERSION-fpm stop
		service php$DEFAULT_PHP_VERSION-fpm start
	fi
}

debugEnv () {
	echo $1
	echo "INSTALLED_AS_USER: $INSTALLED_AS_USER"
	echo "INSTALLED_AS_HOME: $INSTALLED_AS_HOME"
	echo "INSTALLED_FOR_USER: $INSTALLED_FOR_USER"
	echo "INSTALLED_FOR_HOME: $INSTALLED_FOR_HOME"
	echo "WSLDP_GLOBAL_CONFIG_DIR: $WSLDP_GLOBAL_CONFIG_DIR"
	echo "WSLDP_GLOBAL_DIR: $WSLDP_GLOBAL_DIR"
	echo "WSLDP_GLOBAL_BIN_DIR: $WSLDP_GLOBAL_BIN_DIR"
	echo "WSLDP_GLOBAL_LIB_DIR: $WSLDP_GLOBAL_LIB_DIR"
}
