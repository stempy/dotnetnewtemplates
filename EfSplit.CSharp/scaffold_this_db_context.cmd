@echo off
SETLOCAL
echo ======================================================
echo Scaffolds ContextName db context from db connection string such as
echo connection string =%1  
echo ENV_NAME=ENV_DB_CONNECTIONSTR_NAME
echo ======================================================
set thisDir=%~dp0
set thisDir=%thisDir:~0,-1%
set dbcontext=CONTEXT_NAME
set conn=%~1
set prov=Microsoft.EntityFrameworkCore.SqlServer

set thisContextDir=%thisDir%\Db.Context
set thisModelsDir=%thisDir%\Db.Models
set AsmRenameDir=%thisDir%\AsmRename

if "%conn%"=="" (
    if "%ENV_DB_CONNECTIONSTR_NAME%"=="" echo Connection string not in environment or parameter & exit /b 1
    echo ENV_DB_CONNECTIONSTR_NAME=%ENV_DB_CONNECTIONSTR_NAME%
    set conn=%ENV_DB_CONNECTIONSTR_NAME%
)

if "%scaffold_options%"=="" (
    set scaffold_options=SCAFFOLD_OPTIONS
)

if NOT "%scaffold_options%"=="" (
    echo scaffold_options=%scaffold_options%    
)

pushd "%thisContextDir%"

if NOT exist "*.csproj" echo No .csproj file & goto :end
if exist "%dbcontext%.cs" del "%dbcontext%.cs"
dotnet restore
if "%dbcontext%"=="" echo Please specify a context name, ie MasterEntityCore & goto :end
if "%conn%"=="" echo No database connection specified & goto :end
set contextOut=%dbcontext%
if not exist %contextOut% md %contextOut%
call dotnet ef dbcontext scaffold "%conn%" %prov% -c "%dbcontext%" -o "%contextOut%" %scaffold_options%

rem move context and modeld
copy "%contextOut%\%dbcontext%.cs" "%thisContextDir%\%dbcontext%.cs"
del "%contextOut%\%dbcontext%.cs"

rem replace namespace Db.CONTEXT_NAME.Context.CONTEXT_NAME ---- to Db.CONTEXT_NAME.Context
rem         namespace Db.CONTEXT_NAME.Contect.CONTEXT_NAME ---- to Db.CONTEXT_NAME.Models


if not exist "%thisModelsDir%\Models" md "%thisModelsDir%\Models"
copy "%contextOut%\*.cs" "%thisModelsDir%\Models"
del "%contextOut%\*.cs"
rd /q "%contextOut%" 

rem ------------------ WARNING WARNING WARNING -------------------------------------------------------
rem adjust namespaces to match ----- could be ERROR PRONE 6/4/2018   !!!!
cd "%AsmRenameDir%"
dotnet run "%thisModelsDir%\Models" "*.cs" "namespace Db.CONTEXT_NAME.Context.CONTEXT_NAME" "namespace Db.CONTEXT_NAME.Models"
dotnet run "%thisContextDir%" "%dbcontext%.cs" "namespace Db.CONTEXT_NAME.Context.CONTEXT_NAME" "using Db.CONTEXT_NAME.Models; namespace Db.CONTEXT_NAME.Context"
rem adjust namespaces to match ----- could be ERROR PRONE 6/4/2018   !!!!
rem ------------------ WARNING WARNING WARNING -------------------------------------------------------

cd "%thisContextDir%"
dotnet build
popd

pushd "%thisDir%"
dotnet new sln --name Db.CONTEXT_NAME
dotnet sln add Db.Context\Db.CONTEXT_NAME.Context.csproj
dotnet sln add Db.Models\Db.CONTEXT_NAME.Models.csproj
popd


set scaffold_options=
:end
ENDLOCAL & set scaffold_options=