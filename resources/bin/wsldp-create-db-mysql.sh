#!/bin/bash

# TODO

WSLDP_GLOBAL_CONFIG_DIR=
if [ -f $WSLDP_GLOBAL_CONFIG_DIR/defaults ]; then
    source $WSLDP_GLOBAL_CONFIG_DIR/defaults
else
    echo "$WSLDP_GLOBAL_CONFIG_DIR/defaults is missing. Aborting."
    exit
fi

if [ ! -f ~/.my.cnf ]; then
    cat > ~/.my.cnf << EOF
[client]
user=
password=
host=
EOF
    chmod 0600 ~/.my.cnf
fi

if [ "$1" ]; then
    DB=$1
    mysql -p -e "CREATE DATABASE IF NOT EXISTS \`$DB\` DEFAULT CHARACTER SET utf8mb4 DEFAULT COLLATE utf8mb4_unicode_ci"
else
    echo "Error: missing required parameters."
    echo "Usage: "
    echo "  wsldp-create-db-mysql dbname"
fi
