#!/bin/bash

#
# "web driver"
if [ "$WEB_DRIVER" == "y" ]; then
	echoBanner "CHROMIUM WEB DRIVER"
	checkIfInstalled "webdriver" "CHROMIUM WEB DRIVER"
	if [ "$?" == "0" ]; then
		apt-get $APT_SILENCE install -y libxpm4 libxrender1 libgtk2.0-0 libnss3 libgconf-2-4 chromium-browser \
		xvfb gtk2-engines-pixbuf xfonts-cyrillic xfonts-100dpi xfonts-75dpi xfonts-base xfonts-scalable x11-apps
		setAsInstalled "webdriver"
	fi
fi
