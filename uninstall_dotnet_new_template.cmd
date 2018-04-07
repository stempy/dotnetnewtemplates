@echo off
SETLOCAL
set thisDir=%~dp0
set thisDir=%thisDir:~0,-1%
rem ===========================
rem Installs ef class lib template
rem dotnet new efclasslib
rem ===========================
dotnet new -u "%thisDir%\EfSplit.CSharp"
ENDLOCAL
