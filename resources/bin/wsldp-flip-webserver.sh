#!/bin/bash

# TODO - generalnie nie ma tego skryptu - nigdzie nie jest kopiowany

WSLDP_GLOBAL_CONFIG_DIR=
if [ -f $WSLDP_GLOBAL_CONFIG_DIR/defaults ]; then
    source $WSLDP_GLOBAL_CONFIG_DIR/defaults
else
    echo "$WSLDP_GLOBAL_CONFIG_DIR/defaults is missing. Aborting."
    exit
fi

ps auxw | grep apache2 | grep -v grep > /dev/null
if [ $? != 0 ]; then
    service nginx stop > /dev/null
    echo 'nginx stopped'
    service apache2 start > /dev/null
    echo 'apache started'
else
    service apache2 stop > /dev/null
    echo 'apache stopped'
    service nginx start > /dev/null
    echo 'nginx started'
fi
