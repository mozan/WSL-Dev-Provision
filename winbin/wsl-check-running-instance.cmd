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

IF "%1" == "/?" (
    ECHO wsl-check-running-distro distro
    ECHO   distro - name of the distro
    ECHO Sets ERRORLEVEL = 0 if true, -1 if false
)

IF "%1" == "%RUNNING_DISTRO%" (
    EXIT /b 0
) ELSE (
	EXIT /b -1
)
