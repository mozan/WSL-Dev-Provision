#!/bin/bash

source ./_init.sh

CWD=$(pwd)

if [ "$USE_LD_PRELOAD_SOCKOPT" == "y" ] && [ "$RUNNING_ON" == "wsl" ] ;then
    cd resources/lib
    gcc -fPIC -c -o sockopt-stub.o sockopt-stub.c
    gcc -shared -o sockopt-stub.so sockopt-stub.o -ldl

    mkdir -p $WSLDP_GLOBAL_LIB_DIR/wsldp/ 2> /dev/null
    mv sockopt-stub.so $WSLDP_GLOBAL_LIB_DIR/wsldp/ 2> /dev/null

    echo "export LD_PRELOAD=$WSLDP_GLOBAL_LIB_DIR/wsldp/sockopt-stub.so" >> /etc/profile.d/ld_preload.sh
fi

cd $CWD
