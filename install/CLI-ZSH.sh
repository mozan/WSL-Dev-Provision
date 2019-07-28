#!/bin/bash

# ZSH
if [ "$INSTALL_CLI_ZSH" == "y" ]; then
    echoBanner "CLI - ZSH"
    checkIfInstalled "cli-zsh" "CLI - ZSH"
    if [ "$?" == "0" ]; then
        apt-get $APT_SILENCE install -y zsh powerline fonts-powerline
        rm -R $INSTALLED_AS_HOME/.oh-my-zsh 2> /dev/null

        git clone git://github.com/robbyrussell/oh-my-zsh.git $INSTALLED_AS_HOME/.oh-my-zsh
        cp $INSTALLED_AS_HOME/.oh-my-zsh/templates/zshrc.zsh-template $INSTALLED_AS_HOME/.zshrc
        printf "\nsource ~/.bash_aliases\n" | tee -a $INSTALLED_AS_HOME/.zshrc
        printf "\nsource ~/.profile\n" | tee -a $INSTALLED_AS_HOME/.zshrc
        chown -R $INSTALLED_AS_USER:$INSTALLED_AS_USER $INSTALLED_AS_HOME/.oh-my-zsh
        chown $INSTALLED_AS_USER:$INSTALLED_AS_USER $INSTALLED_AS_HOME/.zshrc

        # copy to INSTALLED_FOR if requested
        checkIfInstalledForEqualsInstalledAs
        if [ "$?" != "-1" ]; then
            FOR_HOME="y"
        fi
        if [ "$FOR_HOME" == "y" ]; then
            mkdir $INSTALLED_FOR_HOME/.oh-my-zsh 2> /dev/null
            cp -au $INSTALLED_AS_HOME/.oh-my-zsh $INSTALLED_FOR_HOME/ 2> /dev/null
            cp -u $INSTALLED_AS_HOME/.zshrc $INSTALLED_FOR_HOME/ 2> /dev/null
            chown -R $INSTALLED_FOR_USER:$INSTALLED_FOR_USER $INSTALLED_FOR_HOME/.oh-my-zsh
            chown $INSTALLED_FOR_USER:$INSTALLED_FOR_USER $INSTALLED_FOR_HOME/.zshrc
        fi

        # copy to /root if requested
        if [ "$ADD_ALIASES_TO_ROOT_ACCOUNT" == "y" ]; then
            mkdir /root/.oh-my-zsh 2> /dev/null
            cp -au $INSTALLED_AS_HOME/.oh-my-zsh /root/ 2> /dev/null
            cp -u $INSTALLED_AS_HOME/.zshrc /root/ 2> /dev/null
            chown -R root:root /root/.oh-my-zsh
            chown $INSTALLED_FOR_USER:$INSTALLED_FOR_USER /root/.zshrc
        fi

        setAsInstalled "cli-zsh"
    fi
fi
