#!/bin/bash

source ./_init.sh

echoBanner "up" "Cleaning"

apt-get $APT_SILENCE -y autoremove
apt-get $APT_SILENCE -y clean

chown -Rf $INSTALLED_FOR_USER:$INSTALLED_FOR_USER $INSTALLED_FOR_HOME
