@echo off
REM ac is a symlink to alacritty.exe

SET curpath=%~dp0
SET CWD=%curpath:~0,-1%

REM Get current default WSL DISTRIBUTION
REM Absurd magic to set the DEFAULT_WSL_DISTRO variable from 'lxrunoffline gd' output [SET /P doesn't accept unicode]
COPY %CWD%\.unicode.header %TEMP%\~wsl~default~temp >NUL
lxrunoffline gd >>%TEMP%\~wsl~default~temp
TYPE %TEMP%\~wsl~default~temp > %TEMP%\~wsl~default~temp~ansi
SET /p DEFAULT_WSL_DISTRO=<%TEMP%\~wsl~default~temp~ansi
DEL %TEMP%\~wsl~default~temp > NUL
DEL %TEMP%\~wsl~default~temp~ansi > NUL

IF "%~1" == "/l" (
	wslconfig /l
	GOTO :eof
)

IF "%~1" == "" (
	SET WSL_DISTRO=%DEFAULT_WSL_DISTRO%
	SET WSL_DISTRO_NAME=%DEFAULT_WSL_DISTRO%
) ELSE (
	SET WSL_DISTRO=%~1
	SET WSL_DISTRO_NAME=%~1
)
@lxrunoffline ae -f -n %WSL_DISTRO% -v WSL_DISTRO=%WSL_DISTRO%

START /B ac -t %WSL_DISTRO_NAME% -e lxrunoffline r -n %WSL_DISTRO%
