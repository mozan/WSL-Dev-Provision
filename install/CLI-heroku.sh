#!/bin/bash

#
# Heroku CLI
if [ "$INSTALL_CLI_HEROKU" == "y" ]; then
	echoBanner "CLI - Heroku"
	checkIfInstalled "cli-heroku" "CLI - Heroku"
	if [ "$?" == "0" ]; then
		curl -sL https://cli-assets.heroku.com/install-ubuntu.sh | bash

		chown -R $INSTALLED_FOR_USER:$INSTALLED_FOR_USER $INSTALLED_FOR_HOME/.cache 2> /dev/null
		chown -R $INSTALLED_FOR_USER:$INSTALLED_FOR_USER $INSTALLED_FOR_HOME/.local 2> /dev/null

		setAsInstalled "cli-heroku"
	fi
fi
