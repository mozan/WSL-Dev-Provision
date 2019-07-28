@ECHO off
REM LxRunOffline.exe - https://github.com/DDoSolitary/LxRunOffline

SET run=false
SET RUNNING_DISTRO=

CALL wsl-get-running-instance.cmd

IF NOT "%~1" == "" IF NOT "%1" == "" SET run=true

IF "%run%" == "true" (
    lxrunoffline r -n %1 -c "ps -aux"
    GOTO :eof
)

IF NOT "%RUNNING_DISTRO%" == "" (
	ECHO Running distro: %RUNNING_DISTRO%
	lxrunoffline r -n %RUNNING_DISTRO% -c "ps -aux"
)
