#!/bin/bash

#
# Based on an excelent article - https://blog.ropnop.com/configuring-a-pretty-and-usable-terminal-emulator-for-wsl
#

#
# XWindows related
if [ "$INSTALL_X" == "y" ]; then
	echoBanner "XWindows stuff"
	ADDED_TO_MEMOIRE=n
	apt-get $APT_SILENCE install -y dbus-x11
	dbus-uuidgen --ensure

	if [ "$INSTALL_XFCE4" == "y" ]; then
		echoBanner "XFCE4"
		checkIfInstalled "x-xfce4" "XFCE4"
		if [ "$?" == "0" ]; then
			apt-get $APT_SILENCE install -y xfce4 --no-install-recommends
			ADDED_TO_MEMOIRE=y
			setAsInstalled "x-xfce4"
		fi
	fi

	if [ "$INSTALL_TERMINATOR" == "y" ]; then
		echoBanner "Terminator terminal"
		checkIfInstalled "x-terminator" "Terminator terminal"
		if [ "$?" == "0" ]; then
			apt-get $APT_SILENCE install -y terminator
			installAliases ./resources/shell/bash_aliases_xwindows
			ADDED_TO_MEMOIRE=y
			setAsInstalled "x-terminator"
		fi
	fi

	cp ./resources/profile.d/xwindows-display.sh /etc/profile.d/
	mkdir -p /home/$INSTALLED_AS_USER/.config/terminator
	touch /home/$INSTALLED_AS_USER/.config/terminator/config

	if [ "$ADDED_TO_MEMOIRE" == "y" ]; then
		addToMemoire "Start an XServer on host. Otherwise X based apps won't work."
	fi
fi
