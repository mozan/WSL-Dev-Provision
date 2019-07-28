@ECHO off

SET curpath=%~dp0
SET CWD=%curpath:~0,-1%
SET RUNNING_DISTRO=

REM Get running WSL DISTRIBUTION
COPY %CWD%\.unicode.header %TEMP%\~wsl~default~temp > NUL
wslconfig /l /running >>%TEMP%\~wsl~default~temp
TYPE %TEMP%\~wsl~default~temp > %TEMP%\~wsl~default~temp~ansi
FINDSTR /V "Windows Subsystem for Linux Distributions:" %TEMP%\~wsl~default~temp~ansi > %TEMP%\~wsl~running-distro
SET /p RUNNING_DISTRO=<%TEMP%\~wsl~running-distro
SET RUNNING_DISTRO=%RUNNING_DISTRO: (Default)=%
DEL %TEMP%\~wsl~default~temp > NUL
DEL %TEMP%\~wsl~default~temp~ansi > NUL
DEL %TEMP%\~wsl~running-distro > NUL

IF "%RUNNING_DISTRO%" == "There are no running distributions." (
	SET RUNNING_DISTRO=
	GOTO :eof
)

IF "%1" == "n" (
    ECHO %RUNNING_DISTRO%
)

IF "%1" == "/?" (
    ECHO wsl-get-running-distro silent
    ECHO   silent - y/n - default y
)
