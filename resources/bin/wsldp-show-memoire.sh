#!/bin/bash

WSLDP_GLOBAL_CONFIG_DIR=

if [ -f $WSLDP_GLOBAL_CONFIG_DIR/defaults ]; then
    source $WSLDP_GLOBAL_CONFIG_DIR/defaults
else
    echo "$WSLDP_GLOBAL_CONFIG_DIR/defaults is missing. Aborting."
    exit
fi

cat $WSLDP_GLOBAL_CONFIG_DIR/$MEMOIRE_FILE
