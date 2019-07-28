#!/bin/bash

WSLDP_GLOBAL_CONFIG_DIR=
if [ -f $WSLDP_GLOBAL_CONFIG_DIR/defaults ]; then
    source $WSLDP_GLOBAL_CONFIG_DIR/defaults
else
    echo "$WSLDP_GLOBAL_CONFIG_DIR/defaults is missing. Aborting."
    exit
fi

CUR_DATE=$(date +%m%d%y_%H%M%S_%N)
TMP_HOSTS_FILE=hosts.$CUR_DATE
TMP_HOSTS=/tmp/$TMP_HOSTS_FILE

END_LINE="\\n"
if [ "$RUNNING_ON" == "wsl" ]; then
     END_LINE="\\r\\n"
fi

cp $HOSTS_FILE $TMP_HOSTS 2> /dev/null

# Remove any WSLDP entries from hosts file and prepare for adding new ones
sed -i "/### WSLDP-$INSTANCE_NAME-SITES-BEGIN/,/### WSLDP-$INSTANCE_NAME-SITES-END/d" $TMP_HOSTS
printf "### WSLDP-$INSTANCE_NAME-SITES-BEGIN$END_LINE### WSLDP-$INSTANCE_NAME-SITES-END" | sudo tee -a $TMP_HOSTS > /dev/null

if [ "$RUNNING_ON" == "wsl" ]; then
    cp $TMP_HOSTS $C_MOUNTPOINT/Temp/$TMP_HOSTS_FILE 2> /dev/null
    $NIRCMDC_EXE elevate cmd.exe /C "copy c:\Temp\\$TMP_HOSTS_FILE c:\Windows\System32\drivers\etc\hosts"
else
    sudo cp $TMP_HOSTS $HOSTS_FILE 2> /dev/null
fi 
rm $TMP_HOSTS 2> /dev/null
