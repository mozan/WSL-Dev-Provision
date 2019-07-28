@ECHO off
REM LxRunOffline.exe - https://github.com/DDoSolitary/LxRunOffline

IF "%1" == "/?" GOTO :help

SET RUNNING_DISTRO=
SET DESTINATION=C:\VMs\WSL

REM REM Check if WSL instance %2 is running
CALL wsl-check-running-instance.cmd %2

IF "%ERRORLEVEL%" == "0" (
	ECHO %2 is running
	ECHO To check what is running inside: wsl-ps %2
	ECHO To terminate it: wsl-terminate %2
	GOTO :end
)

IF NOT "%1" == "" (
	IF NOT "%2" == "" (
		wslconfig /u %2 > NUL
		LxRunOffline.exe duplicate -n %1 -N %2 -d "%DESTINATION%\%2"
		IF NOT "%3" == "" (
			IF "%3" == "true" wslconfig /s %2
		)
		wslconfig /l
		GOTO :end
	)
)

:help
ECHO wsl-duplicate-instance source destination
ECHO   source - source distribution name
ECHO   destination - destination distribution name
ECHO   default - true or false - set as default distribution (default: false)
ECHO.
ECHO Available:
wslconfig /l

:end
