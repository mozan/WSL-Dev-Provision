#!/bin/bash

#
# Ruby / rbenv / rails
if [ "$INSTALL_RUBY" == "y" ]; then
	echoBanner "Ruby"
	checkIfInstalled "ruby" "Ruby"
	if [ "$?" == "0" ]; then
		apt-get $APT_SILENCE install -y libssl-dev libyaml-dev libxml2-dev libxslt1-dev libcurl4-openssl-dev software-properties-common libffi-dev libreadline-dev

		DEST_DIR=$INSTALLED_FOR_HOME
		RBENV_DIR=$DEST_DIR/.rbenv

		rm -R $RBENV_DIR 2> /dev/null
		git clone https://github.com/rbenv/rbenv.git $RBENV_DIR

		CWD=$(pwd)
		cd $RBENV_DIR && src/configure && make -C src && cd -
		echo "export PATH=\"$RBENV_DIR/bin:$RBENV_DIR/plugins/ruby-build/bin:$PATH\"" >> $INSTALLED_FOR_HOME/.profile
		echo 'eval "$(rbenv init -)"' >> $INSTALLED_FOR_HOME/.profile

		rm -R $RBENV_DIR/plugins/ruby-build 2> /dev/null
		git clone https://github.com/rbenv/ruby-build.git $RBENV_DIR/plugins/ruby-build

		chown -Rf $INSTALLED_FOR_USER:$INSTALLED_FOR_USER $RBENV_DIR

		sudo -i -u $INSTALLED_FOR_USER -- rbenv install 2.6.3
		sudo -i -u $INSTALLED_FOR_USER -- rbenv global 2.6.3
		sudo -i -u $INSTALLED_FOR_USER -- rbenv rehash
		sudo -i -u $INSTALLED_FOR_USER -- gem install rails -v 5.2.3

		cd $CWD

		addToMemoire "Ruby: HEADS UP! i18n 1.1 changed fallbacks to exclude default locale. But that may break your application. https://github.com/svenfuchs/i18n/releases/tag/v1.1.0"
		setAsInstalled "ruby"
	fi
fi
