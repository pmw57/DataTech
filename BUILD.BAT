@echo off

REM PAWILK09 2013-09-26 Update so that bulding works consistantly without needing trailing slash.
REM          The HARB____.BAT files how all work consistantly as expected.
REM PAWILK09 2013-09-27 Add file check so that when build.bat is run without a valid .HBP file,
REM          a suitable error message is shown.
REM          Now uses HBP variable instead of %1 so that the code is easier to understand.

cls

ECHO Build from a Harbour HBP file and optionally build to a desired output folder
ECHO.

if "%1"=="/?" GOTO HELP
GOTO SETVARS

:HELP
ECHO.
ECHO BUILD [/r ^| /run] hbpfile [destination]
ECHO.
ECHO   hbpfile         Specifies the name of the Harbour project file.
ECHO                   If the project file was METMAIN.HBP then the
ECHO                   hbpfile is METMAIN
ECHO   destination     Specifies the new location of the built program.
ECHO.
ECHO   /run            After building, changes directory to the output
ECHO                   destination and runs the program.
ECHO.
ECHO   Examples:
ECHO   BUILD METMAIN
ECHO   BUILD /r METMAIN METDBF\
ECHO   BUILD /r METMAIN C:\DATATECH\METDBF\
ECHO.
GOTO END

:SETVARS
REM the buildpath is the location of the build.bat file
SET BUILDPATH=%~dp0
SET RUN=FALSE
SET HBP=
SET OUT=
GOTO CHECKRUN

:CHECKRUN
IF "%1"=="/r" GOTO SETRUN
IF "%1"=="/run" GOTO SETRUN
GOTO SETHBP

:SETRUN
SET RUN=TRUE
SHIFT
GOTO SETHBP

:SETHBP
SET HBP=%1
IF NOT EXIST %HBP%.HBP GOTO HBPERROR
GOTO SETOUT

:SETOUT
SET OUT=%2
IF "%2"=="" SET OUT=%BUILDPATH%%HBP%\
GOTO BUILD

:BUILD
call :DETAILS

CD /d %BUILDPATH%
ECHO Building from %BUILDPATH%%HBP%.HBP
ECHO program destination %OUT%%HBP%.EXE
ECHO.
CALL c:\hmg.3.2\build.bat /n %HBP% -o%OUT%

IF "%RUN%"=="TRUE" GOTO RUN
GOTO END

:RUN
CD /d %OUT%
ECHO.
ECHO "  This is Harbour    %HBP% "
PAUSE

%HBP%.EXE
CD ..
GOTO END

:HBPERROR
ECHO Error: The build file %HBP%.HBP is missing.
ECHO Please provide the name of an existing .HBP file.
ECHO.
CALL :DETAILS
GOTO END

:DETAILS
ECHO See build /? for details
ECHO.
GOTO :EOF

:END
REM Cleanup
SET BUILDPATH=
SET OUT=
SET RUN=