@ECHO OFF
SETLOCAL

ECHO.

SET THIS=%0
SET THIS_DIR=%~dp0

SET PRJ_ARG=%1
IF NOT "%PRJ_ARG%"=="" GOTO :found_prj_arg
ECHO *** MISSING PROJECT NAME ARGUMENT!!! ***
GOTO :eof

:found_prj_arg
SET BUILDNO=%APPVEYOR_BUILD_NUMBER%
IF "%BUILDNO%"=="" SET BUILDNO=0

ECHO Building %PRJ_ARG% (build #%BUILDNO%)

REM --- Try to find NuGet on the path
FOR /F "delims=" %%i IN ('where nuget.* /F') DO set NUGET=%%i

REM --- If not found, look for NuGet at fixed location (in AppVeyor)
IF NOT EXIST "nuget-build.cmd" SET FOO=BAR
IF NOT EXIST "%NUGET%" SET NUGET="%THIS_DIR%..\..\..\nuget\nuget.exe"
IF NOT EXIST %NUGET% (
	ECHO --^> ERROR: Cannot Find Nuget: Please ensure Nuget is installed and available on your path
	ECHO.
	GOTO :eof
)

ECHO Using NuGet located at %NUGET%

SET NUGET_PRJ="%THIS_DIR%%PRJ_ARG%\%PRJ_ARG%.csproj"
SET NUGET_OUT="%THIS_DIR%dist\nuget"

IF NOT EXIST %NUGET_OUT% MD %NUGET_OUT%

SET NUGET_PROPS=nugetCwd=%CD%
SET NUGET_PROPS=%NUGET_PROPS%;nugetDate=%DATE%
SET NUGET_PROPS=%NUGET_PROPS%;nugetTime=%Time%
SET NUGET_PROPS=%NUGET_PROPS%;buildNum=%BUILDNO%
SET NUGET_PROPS=%NUGET_PROPS%;versionLabel=-EA

:Execute_NuGet
%NUGET% pack -Properties "%NUGET_PROPS%" -OutputDirectory %NUGET_OUT% %NUGET_PRJ%

ECHO.