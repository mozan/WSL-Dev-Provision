@echo off

IF NOT "%1" == "" (
	wslconfig /t %1
	GOTO :eof
) ELSE (
	ECHO wsl-terminate instance
	ECHO   instance - instance name
	ECHO.
	ECHO Running WSL instances:
	wslconfig /l /running
)
