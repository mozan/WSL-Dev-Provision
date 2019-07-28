#!/bin/bash

source ./params.sh

if [ -d "$SELF_UPDATE_DIR" ]; then
	rm -R *
	cp -R $SELF_UPDATE_DIR/* .
fi
