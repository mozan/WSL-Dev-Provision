#!/bin/bash

WSLDP_GLOBAL_CONFIG_DIR=
if [ -f $WSLDP_GLOBAL_CONFIG_DIR/defaults ]; then
    source $WSLDP_GLOBAL_CONFIG_DIR/defaults
else
    echo "$WSLDP_GLOBAL_CONFIG_DIR/defaults is missing. Aborting."
    exit
fi

TMP_HOSTS_FILE=hosts.$(date +%m%d%y_%H%M%S_%N)
TMP_HOSTS=/tmp/$TMP_HOSTS_FILE

END_LINE="\\n"
if [ "$RUNNING_ON" == "wsl" ]; then
     END_LINE="\\r\\n"
fi

# Add new IP/host pair to hosts file
if [[ "$1" && "$2" ]]; then
    IP=$1
    HOSTNAME=$2

    cp $HOSTS_FILE $TMP_HOSTS 2> /dev/null

    if [ -n "$(grep [^\.]$HOSTNAME $TMP_HOSTS)" ]; then
        echo "$HOSTNAME already exists in hosts file " $(grep [^\.]$HOSTNAME $TMP_HOSTS)
    else
        sed -i "/### WSLDP-$INSTANCE_NAME-SITES-BEGIN/c\### WSLDP-$INSTANCE_NAME-SITES-BEGIN$END_LINE$IP\t$HOSTNAME" $TMP_HOSTS

        if ! [ -n "$(grep [^\.]$HOSTNAME $TMP_HOSTS)" ]; then
            echo "Failed to add $HOSTNAME, try again!"
        else
            if [ "$RUNNING_ON" == "wsl" ]; then
                cp $TMP_HOSTS $C_MOUNTPOINT/Temp/$TMP_HOSTS_FILE 2> /dev/null
                $NIRCMDC_EXE elevate cmd.exe /C "copy c:\Temp\\$TMP_HOSTS_FILE c:\Windows\System32\drivers\etc\hosts && ping -n 1 $HOSTNAME"
            else
                sudo cp $TMP_HOSTS $HOSTS_FILE 2> /dev/null
            fi 
        fi
        echo -n "Added to system hosts file: "
        echo $(grep [^\.]$HOSTNAME $TMP_HOSTS)
        rm $TMP_HOSTS 2> /dev/null
    fi
else
    echo "wsldp-hosts-add ip host"
    echo "  ip - for example 192.168.0.222"
    echo "  host - for example blah.local"
fi
