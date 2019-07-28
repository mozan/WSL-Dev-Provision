@echo off

IF "%1" == "" (
	ECHO All instances
	ECHO.
	wslconfig /l
	GOTO :eof
)

IF "%1" == "y" (
	ECHO Running instances
	ECHO.
	wslconfig /l /running
	GOTO :eof
)

ECHO wsl-list-instances only-running
ECHO   only-running - y/n (default n)
ECHO.
