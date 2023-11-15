@echo off
REM -------------------------------------------------------------
REM DumpDC 1.0.3
REM -------------------------------------------------------------

set LOGFILE=DumpDC-%COMPUTERNAME%.log

echo [i] Starting execution on %COMPUTERNAME% at %DATE% - %TIME% > %LOGFILE%

REM SET COLOR TO SIGNIFY THE SCRIPT IS RUNNING
cls
color

REM PROMPT WARNING
echo This batch file will gather all of the current group policies and password
echo hashes for the current domain.  It will place this into a single file when
echo it is finished running.
echo.
echo Running DUMPIT may temporarily deviate standard system performance.
echo.
set /p CROWECONTINUE="Are you sure you want to continue (Y\N)? "

IF %CROWECONTINUE%==Y ( GOTO ASK )
IF %CROWECONTINUE%==y ( GOTO ASK )
echo [*] %TIME%: User declined to continue the script, exiting. >> %LOGFILE%
GOTO END
:ASK

REM Check to see if the GPMC is installed
echo [------------------------------TESTING FOR GPMC ------------------------------]
cscript /nologo GPOTest.wsf >> %LOGFILE% 2>&1

IF %ERRORLEVEL% == 1 (GOTO START_GPMC_ERROR)

GOTO END_GPMC_ERROR
:START_GPMC_ERROR
echo [!] %TIME%: Fatal error, GPMC is not installed, exiting. >> %LOGFILE%

color 47
echo.
echo [********************************** ERROR ************************************]
echo.
echo The group policy management console does not appear to be installed on
echo this system.  Please run this script on a system which has it installed.
echo.
echo Press any key to quit . . .
echo 
pause > nul

REM RESET COLOR TO SIGNIFY THE SCRIPT IS COMPLETED
cls
color
GOTO END
:END_GPMC_ERROR


REM Reset the color so that the user sees we're doing something.
color 0E
cls
echo [----------------------------------- SETUP -----------------------------------]
REM QUESTION TYPE OF DUMP TO PERFORM
set /p CROWEPWDUMP="Should password hashes be dumped (Y\N)? "
IF %CROWEPWDUMP%==Y ( GOTO START_DUMPPW )
IF %CROWEPWDUMP%==y ( GOTO START_DUMPPW )

GOTO END_DUMPPW
:START_DUMPPW
echo [i] %TIME%: User requested that password hashes be dumped. >> %LOGFILE%
:END_DUMPPW

set /p CROWECLEANUP="Should DumpIT delete itself when finished (Y/N)? "

REM Set the color to something better
color

REM DEFINE VARIABLES
SET CROWE_DUMP_PATH=%CD%

echo [i] %TIME%: Dump path set to "%CROWE_DUMP_PATH%". >> %LOGFILE%

REM -------------------------------------------------------------
REM SETUP
REM -------------------------------------------------------------
cls
echo [********************************* STARTING **********************************]

REM -------------------------------------------------------------
REM DUMP GROUP POLICY INFORMATION
REM -------------------------------------------------------------
echo [--------------------------- DUMPING GROUP POLICY ----------------------------]
echo [i] %TIME%: Starting group policy dump >> %LOGFILE%
gpresult /v > "%CROWE_DUMP_PATH%\%computername%_gpresult.txt" | tee -a %LOGFILE%
echo Group policies dumped to gpresult.txt

cscript /nologo "%CROWE_DUMP_PATH%\ListAllGPOs.wsf" > "%CROWE_DUMP_PATH%\%computername%_listall.txt" | tee -a %LOGFILE%
echo GPOs added to listall.txt

cscript /nologo "%CROWE_DUMP_PATH%\FindDisabledGPOs.wsf" > "%CROWE_DUMP_PATH%\%computername%_disabled.txt" | tee -a %LOGFILE%
echo Disabled GPOs added to disabled.txt

cscript /nologo "%CROWE_DUMP_PATH%\FindUnlinkedGPOs.wsf" > "%CROWE_DUMP_PATH%\%computername%_unlinked.txt" | tee -a %LOGFILE%
echo Unliked GPOs added to unlinked.txt

cscript /nologo "%CROWE_DUMP_PATH%\GetReportsForAllGPOs.wsf" "%CROWE_DUMP_PATH%" 2>&1 | tee -a %LOGFILE%
echo All GPO Reports dumped
echo [i] %TIME%: Group policy dump done >> %LOGFILE%

REM -------------------------------------------------------------
REM DUMP PASSWORD HASHES
REM -------------------------------------------------------------
REM Did the user tell us to dump passwords?
IF %CROWEPWDUMP%==Y ( GOTO START_DUMPPW )
IF %CROWEPWDUMP%==y ( GOTO START_DUMPPW )

GOTO END_PW
:START_DUMPPW
	echo [---------------------------- DUMPING PASSWORDS ------------------------------]
	echo [i] %TIME%: Starting ntdsutil >> %LOGFILE%
	ntdsutil "activate instance ntds" "ifm" "create full """%CROWE_DUMP_PATH%\CroweNTDS"""" "quit" "quit"
	echo ntdsutil done
		echo [i] %TIME%: ntdsutil done. >> %LOGFILE%
:END_PW


REM -------------------------------------------------------------
REM CREATE ZIP
REM -------------------------------------------------------------
echo [---------------------------- CREATING ZIP FILE ------------------------------]
echo [i] %TIME%: Creating ZIP file, execution complete. >> %LOGFILE%
"%CROWE_DUMP_PATH%\7z.exe" a -tzip "%CROWE_DUMP_PATH%\DumpIT-%computername%.zip" -x!*.exe -x!*.vbs -x!*.wsf -x!*.js -x!*.cab -x!*.dll -x!*.bat -x!*.zip 2>&1 | tee -a %LOGFILE%
"%CROWE_DUMP_PATH%\7z.exe" a -tzip "%CROWE_DUMP_PATH%\DumpIT-%computername%.zip" %LOGFILE%

IF %CROWECLEANUP%==Y ( GOTO START_EXECLEAN )
IF %CROWECLEANUP%==y ( GOTO START_EXECLEAN )

GOTO END_EXECLEAN
:START_EXECLEAN
	REM -------------------------------------------------------------
	REM CLEAN UP
	REM -------------------------------------------------------------
	IF EXIST "%CROWE_DUMP_PATH%\7z.dll" DEL "%CROWE_DUMP_PATH%\7z.dll"
	IF EXIST "%CROWE_DUMP_PATH%\7z.exe" DEL "%CROWE_DUMP_PATH%\7z.exe"
	IF EXIST "%CROWE_DUMP_PATH%\tee.exe" DEL "%CROWE_DUMP_PATH%\tee.exe"
	IF EXIST "%CROWE_DUMP_PATH%\GetReportsForAllGPOs.wsf" DEL "%CROWE_DUMP_PATH%\GetReportsForAllGPOs.wsf"
	IF EXIST "%CROWE_DUMP_PATH%\Lib_CommonGPMCFunctions.js" DEL "%CROWE_DUMP_PATH%\Lib_CommonGPMCFunctions.js"
	IF EXIST "%CROWE_DUMP_PATH%\ListAllGPOs.wsf" DEL "%CROWE_DUMP_PATH%\ListAllGPOs.wsf"
	IF EXIST "%CROWE_DUMP_PATH%\FindDisabledGPOs.wsf" DEL "%CROWE_DUMP_PATH%\FindDisabledGPOs.wsf"
	IF EXIST "%CROWE_DUMP_PATH%\FindUnlinkedGPOs.wsf" DEL "%CROWE_DUMP_PATH%\FindUnlinkedGPOs.wsf"
	IF EXIST "%CROWE_DUMP_PATH%\GPOTest.wsf" DEL "%CROWE_DUMP_PATH%\GPOTest.wsf"
:END_EXECLEAN

REM delete files we zipped
IF EXIST "%CROWE_DUMP_PATH%\DumpIT-%computername%.zip" DEL "%CROWE_DUMP_PATH%\*.txt"
IF EXIST "%CROWE_DUMP_PATH%\DumpIT-%computername%.zip" DEL "%CROWE_DUMP_PATH%\*.xml"
IF EXIST "%CROWE_DUMP_PATH%\DumpIT-%computername%.zip" DEL "%CROWE_DUMP_PATH%\*.html"
IF EXIST "%CROWE_DUMP_PATH%\DumpIT-%computername%.zip" DEL "%CROWE_DUMP_PATH%\*.log"

REM clear variables
SET CROWE_DUMP_PATH=
SET CROWEPWDUMP=
SET CROWE64BIT=

REM -------------------------------------------------------------
REM COMPLETE
REM -------------------------------------------------------------
echo.
time/t
echo.
echo [******************************** COMPLETED **********************************]
echo.
echo Please check DumpIT-%computername%.zip for the results.
echo Questions? Please email risklabadmins@crowe.com
echo.
echo Press any key to quit . . .
echo 
pause > nul

REM RESET COLOR TO SIGNIFY THE SCRIPT IS COMPLETED
cls
color

REM DELETE THIS BATCH FILE BECAUSE IT IS DONE RUNNING
IF %CROWECLEANUP%==Y ( GOTO START_BATCLEAN )
IF %CROWECLEANUP%==y ( GOTO START_BATCLEAN )


GOTO END
:START_BATCLEAN
	DEL DumpDC.bat
:END

SET CROWECLEANUP=
