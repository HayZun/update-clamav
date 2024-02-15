@echo off

REM Unblock all files in the folder
for %%F in ("%CD%\*.ps1") do (
    cmd /c powershell -Command "Unblock-File -Path \"%%F\""
)

REM Create repertory C:\Scripts if it doesn't exist
if not exist "C:\Scripts" mkdir "C:\Scripts"

REM Create repertory C:\temp if it doesn't exist
if not exist "C:\temp" mkdir "C:\temp"

REM Move .\update-clamav.ps1 to C:\Scripts
move "%CD%\update-clamav.ps1" "C:\Scripts"


REM Run the PowerShell script
powershell -ExecutionPolicy Bypass -File "%CD%\create_task.ps1"

```