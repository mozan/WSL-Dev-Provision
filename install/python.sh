#!/bin/bash

#
# Python
if [ "$INSTALL_PYTHON" == "y" ]; then
    echoBanner "Python"
    checkIfInstalled "python" "Python"
	if [ "$?" == "0" ]; then
		apt-get $APT_SILENCE install -y python3-pip build-essential libssl-dev libffi-dev python3-dev python3-venv

		mkdir $INSTALLED_FOR_HOME/.cache 2> /dev/null
		mkdir $INSTALLED_FOR_HOME/.local 2> /dev/null
		chown -R $INSTALLED_FOR_USER:$INSTALLED_FOR_USER $INSTALLED_FOR_HOME/.cache 2> /dev/null
		chown -R $INSTALLED_FOR_USER:$INSTALLED_FOR_USER $INSTALLED_FOR_HOME/.local 2> /dev/null

		sudo -H -u $INSTALLED_FOR_USER bash -c 'pip3 install numpy'
	    setAsInstalled "python"
    fi
fi
