#!/bin/bash

#
# .NET Core
if [ "$INSTALL_DOTNET_CORE_SDK" == "y" ]; then
	echoBanner ".NET Core SDK v2.2"
	checkIfInstalled "dotnet-core-sdk" ".NET Core SDK v2.2"
	if [ "$?" == "0" ]; then
		apt-get $APT_SILENCE install -y dotnet-sdk-2.2
		addToMemoire "Microsoft .NET SDK - telemetry. Set DOTNET_CLI_TELEMETRY_OPTOUT environment variable to '1' or 'true' using your favorite shell"
		ADDED_TO_MEMOIRE=y
		setAsInstalled "dotnet-core-sdk"
	fi
fi

if [ "$INSTALL_DOTNET_CORE_RUNTIME" == "y" ]; then
	echoBanner ".NET Core runtime v2.2"
	checkIfInstalled "dotnet-core-runtime" ".NET Core runtime v2.2"
	if [ "$?" == "0" ]; then
		apt-get $APT_SILENCE install -y aspnetcore-runtime-2.2
		if [ "$ADDED_TO_MEMOIRE" != "y" ]; then
			addToMemoire "Microsoft .NET SDK - telemetry. Set DOTNET_CLI_TELEMETRY_OPTOUT environment variable to '1' or 'true' using your favorite shell"
		fi
		setAsInstalled "dotnet-core-runtime"
	fi
fi
