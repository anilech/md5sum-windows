@echo off

set "_algos="
for /f "tokens=2* delims=: " %%a in ('certutil -hashfile -help ^| find /i "SHA"') do set "_algos=%%a %%b"
if "%_algos%"=="" echo unable to determine hash-algorythms&goto :eof

set "_algo="
for %%a in (%_algos%) do if /i "%~n0"=="%%asum" set "_algo=%%a"
if "%_algo%"=="" echo unknown hash algorythm. certutil supports %_algos%&goto :eof

if /i "%1"=="-c" call :check %* && goto :eof

:lup
if "%1"=="" goto :eof
for %%f in (%1) do call :hashFile "%%f"
shift
goto :lup

:: --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
:check
set "hf="
if "%~2" == "-" set hf=`more`
if "%~2" == ""  set hf=`more`
if "%hf%"== ""  set hf="%~2"&if not exist "%~2" echo "%~2 not found"&goto :eof

set _csl=0
if /i "%_algo%" == "MD5"    set _csl=32
if /i "%_algo%" == "SHA1"   set _csl=40
if /i "%_algo%" == "SHA256" set _csl=64
if /i "%_algo%" == "SHA384" set _csl=96
if /i "%_algo%" == "SHA512" set _csl=128
if %_csl% equ 0 goto :eof

for /F "usebackq eol=# delims=" %%l in (%hf%) do call :checkFile "%%l"
goto :eof

:: --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
:checkFile
if "%~1"=="" goto :eof
set "_line=%~1"
call set "_chsh=%%_line:~0,%_csl%%%"
call set "_file=%%_line:~%_csl%%%"
set "_splt=%_file:~0,2%"
set "_file=%_file:~2%"
if not "%_splt%" == "  " if not "%_splt%" == " *" echo bad line: "%_line%"&goto :eof
set "_rhsh="
call :hashFile "%_file%" _rhsh
if /i "%_rhsh%" == "%_chsh%" (echo %_file%: OK) else echo %_file%: FAILED
goto :eof

:: --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
:hashFile
if not exist "%~1" echo file "%~1" not found&goto :eof
set "_hsh="
for /f "tokens=1 delims=" %%q in ('certutil -hashfile "%~1" %_algo% ^| findstr /i /r /c:"^[a-f0-9][a-f0-9 ]*$"') do set "_hsh=%%q"
if "%_hsh%"=="" echo unable to calculate %_algo%-sum of the "%~1"& goto :eof
if not "%~2" == "" (set "%~2=%_hsh: =%") else echo %_hsh: =%  %~1
set "_hsh="
goto :eof
