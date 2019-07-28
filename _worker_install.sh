#!/bin/bash

source ./_init.sh

export DEBIAN_FRONTEND=noninteractive

#
# Locale
echo "LC_ALL=$LOCALE" >> /etc/default/locale
locale-gen en_US.UTF-8

#
# Timezone
echoBanner "timezone" "Updating"
ln -sf /usr/share/zoneinfo/$DEFAULT_TIMEZONE /etc/localtime

#
# Install basics
echoBanner "Basic packages"
apt-get $APT_SILENCE install -y software-properties-common unattended-upgrades build-essential lsb-release \
curl unzip ntp ntpdate whois vim graphviz zsh joe mc gnupg gcc g++ make git libmcrypt4 libpcre3-dev libpng-dev \
python2.7-dev python-pip re2c libnotify-bin daemonize supervisor pv mcrypt bash-completion avahi-daemon apt-transport-https \
imagemagick cifs-utils dos2unix mysql-client-5.7 postgresql-client-common

#
# PPA related
./_ppa.sh

#
# Update system packages
if [ "$UPGRADE_SYSTEM_PACKAGES" == "y" ]; then
	echoBanner "System packages" "Updating"
	apt-get $APT_SILENCE -y upgrade
fi

#
# copy WSLDP certificate creation script
# TODO - what about a password?
echoBanner "WSL root certificate"
checkIfInstalled "wsl-root-certificate" "WSL root certificate"
if [ "$?" == "0" ]; then
	cp ./resources/bin/wsldp-create-certificate.sh $WSLDP_GLOBAL_BIN_DIR/
	chmod +x $WSLDP_GLOBAL_BIN_DIR/wsldp-create-certificate.sh
	setEnvWSLDPScriptsGlobals WSLDP_GLOBAL_CONFIG_DIR $WSLDP_GLOBAL_CONFIG_DIR $WSLDP_GLOBAL_BIN_DIR/wsldp-create-certificate.sh
	# create root WSLDP certificate
	bash $WSLDP_GLOBAL_BIN_DIR/wsldp-create-certificate.sh
    addToMemoire "WSLDP root certificate directory: $WSLDP_GLOBAL_CONFIG_DIR/certificates"
	setAsInstalled "wsl-root-certificate"
fi

#
# copy WSLDP miscs tools, init hosts file
echoBanner "WSL misc tools"
checkIfInstalled "wsl-misc-tools" "WSL misc tools"
if [ "$?" == "0" ]; then
	# CMD - hosts related
	cp ./resources/bin/wsldp-hosts-add.sh $WSLDP_GLOBAL_BIN_DIR/
	setEnvWSLDPScriptsGlobals WSLDP_GLOBAL_CONFIG_DIR $WSLDP_GLOBAL_CONFIG_DIR $WSLDP_GLOBAL_BIN_DIR/wsldp-hosts-add.sh
	sed -i "s#C_MOUNTPOINT=/mnt/c#C_MOUNTPOINT=$C_MOUNTPOINT#" $WSLDP_GLOBAL_BIN_DIR/wsldp-hosts-add.sh
	sed -i "s#INSTANCE_NAME=#INSTANCE_NAME=$INSTANCE_NAME#" $WSLDP_GLOBAL_BIN_DIR/wsldp-hosts-add.sh
	chmod +x $WSLDP_GLOBAL_BIN_DIR/wsldp-hosts-add.sh

	cp ./resources/bin/wsldp-hosts-reset.sh $WSLDP_GLOBAL_BIN_DIR/
	setEnvWSLDPScriptsGlobals WSLDP_GLOBAL_CONFIG_DIR $WSLDP_GLOBAL_CONFIG_DIR $WSLDP_GLOBAL_BIN_DIR/wsldp-hosts-reset.sh
	sed -i "s#C_MOUNTPOINT=/mnt/c#C_MOUNTPOINT=$C_MOUNTPOINT#" $WSLDP_GLOBAL_BIN_DIR/wsldp-hosts-reset.sh
	sed -i "s#INSTANCE_NAME=#INSTANCE_NAME=$INSTANCE_NAME#" $WSLDP_GLOBAL_BIN_DIR/wsldp-hosts-reset.sh
	chmod +x $WSLDP_GLOBAL_BIN_DIR/wsldp-hosts-reset.sh

	# Init system hosts file
	checkIfInstalled "wsl-hosts-was-reseted" "WSL system hosts file ready"
	if [ "$?" == "0" ]; then
		$WSLDP_GLOBAL_BIN_DIR/wsldp-hosts-reset.sh
		setAsInstalled "wsl-hosts-was-reseted"
	fi

# TODO cleanup

	# CMD - DB creation related
	cp ./resources/bin/wsldp-create-db-mysql.sh $WSLDP_GLOBAL_BIN_DIR/
	setEnvWSLDPScriptsGlobals WSLDP_GLOBAL_CONFIG_DIR $WSLDP_GLOBAL_CONFIG_DIR $WSLDP_GLOBAL_BIN_DIR/wsldp-create-db-mysql.sh
	sed -i "s#user=#user=$DB_ADMIN_USERNAME#" $WSLDP_GLOBAL_BIN_DIR/wsldp-create-db-mysql.sh
	sed -i "s#host=#host=$DB_HOST#" $WSLDP_GLOBAL_BIN_DIR/wsldp-create-db-mysql.sh
	chmod +x $WSLDP_GLOBAL_BIN_DIR/wsldp-create-db-mysql.sh

	# CMD - list installed WSLDP packages
	cp ./resources/bin/wsldp-list-installed.sh $WSLDP_GLOBAL_BIN_DIR/
	setEnvWSLDPScriptsGlobals WSLDP_GLOBAL_CONFIG_DIR $WSLDP_GLOBAL_CONFIG_DIR $WSLDP_GLOBAL_BIN_DIR/wsldp-list-installed.sh
	chmod +x $WSLDP_GLOBAL_BIN_DIR/wsldp-list-installed.sh

	# CMD - show memoire file
	cp ./resources/bin/wsldp-show-memoire.sh $WSLDP_GLOBAL_BIN_DIR/
	setEnvWSLDPScriptsGlobals WSLDP_GLOBAL_CONFIG_DIR $WSLDP_GLOBAL_CONFIG_DIR $WSLDP_GLOBAL_BIN_DIR/wsldp-show-memoire.sh
	chmod +x $WSLDP_GLOBAL_BIN_DIR/wsldp-show-memoire.sh

	setAsInstalled "wsl-misc-tools"
fi

#
# install all services
for f in `ls install/*.sh | sort -Vf`; do
	. $f
done

#
# LD_PREOLAD related...
if [ "$RUNNING_ON" == "wsl" ]; then
	if [ "$USE_LD_PRELOAD_SOCKOPT" == "y" ]; then
		echoBanner "LD_PRELOAD related .so files"
		for f in `ls install/ld_preload/*.sh | sort -Vf`; do
			. $f
		done
	fi
fi

#
# Generate the autorun file from params.sh
if [ "$RUNNING_ON" == "wsl" ]; then
	echoBanner "/etc/init.d/autorun"
	fgrep "export INSTALL_SERVICE_" params.sh | grep "=y" | sed "s/export INSTALL_SERVICE_//" | sed "s/\t//" > autorun
	echo "DBUS=y" >> autorun
	cat autorun | sed "s/=y//" > $WSLDP_GLOBAL_CONFIG_DIR/autorun
	rm -f autorun
	cp resources/init.d/autorun-init /etc/init.d/autorun
	sed -i "s#WSLDP_GLOBAL_CONFIG_DIR=#WSLDP_GLOBAL_CONFIG_DIR=$WSLDP_GLOBAL_CONFIG_DIR#" /etc/init.d/autorun
	chmod +x /etc/init.d/autorun

	addToMemoire "sudo /etc/init.d/autorun start|stop - to start/stop all services installed via WSLDP"
fi

#
# One last upgrade check
echoBanner "upgrade check" "Last"
apt-get $APT_SILENCE -y update
apt-get $APT_SILENCE -y upgrade
