#!/bin/bash

source ./_init.sh

# TODO cleanup

# .dir_colors for alacritty windows
cp ./resources/shell/dircolors $INSTALLED_AS_HOME/.dircolors
chown $INSTALLED_AS_USER:$INSTALLED_AS_USER $INSTALLED_AS_HOME/.dircolors

checkIfInstalledForEqualsInstalledAs
if [ "$?" == "-1" ]; then
    cp ./resources/shell/dircolors $INSTALLED_FOR_HOME/.dircolors
    chown $INSTALLED_FOR_USER:$INSTALLED_FOR_USER $INSTALLED_FOR_HOME/.dircolors
fi
if [ "$ADD_ALIASES_TO_ROOT_ACCOUNT" == "y" ]; then
    cp ./resources/shell/dircolors /root/.dircolors
fi

# SSH related
# rm -rf ~/.ssh
# cp -R /mnt/c/Users/$USER/.ssh ~/.ssh
# chmod 600 ~/.ssh/id_rsa

# think about it (scripts) - use them!
HOMESTEAD_REPO_HOME=$(pwd)/../homestead/
echoBanner "Homestead repo to $HOMESTEAD_REPO_HOME" "Cloning"
rm -r $HOMESTEAD_REPO_HOME 2> /dev/null
git clone https://github.com/mozan/homestead.git $HOMESTEAD_REPO_HOME 2> /dev/null
chown -Rf $INSTALLED_AS_USER:$INSTALLED_AS_USER $HOMESTEAD_REPO_HOME
