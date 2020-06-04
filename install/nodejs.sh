#!/bin/bash

#
# Node.js
if [ "$INSTALL_NODEJS" == "y" ]; then
	echoBanner "NODEJS"
	checkIfInstalled "nodejs" "NODEJS"
	if [ "$?" == "0" ]; then
		curl -sL https://deb.nodesource.com/setup_10.x | bash -
		apt-get $APT_SILENCE install -y nodejs

		mkdir /usr/lib/node_modules/.staging

		echoBanner "NODEJS - bower"
		/usr/bin/npm install -g bower

		echoBanner "NODEJS - grunt"
		/usr/bin/npm install -g grunt-cli

		echoBanner "NODEJS - npm"
		/usr/bin/npm install -g npm

		echoBanner "NODEJS - yarn"
		apt-get $APT_SILENCE install -y yarn

		setAsInstalled "nodejs"
	fi
fi
