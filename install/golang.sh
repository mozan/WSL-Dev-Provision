#!/bin/bash

#
# Golang
if [ "$INSTALL_GOLANG" == "y" ]; then
	echoBanner "GO lang"
	checkIfInstalled "golang" "GO lang"
	if [ "$?" == "0" ]; then
		apt $APT_SILENCE install -y golang-go
		setAsInstalled "golang"
	fi
fi
