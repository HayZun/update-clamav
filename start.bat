@echo off

REM Unblock all files in the folder
for %%F in ("%CD%\*.ps1") do (
    cmd /c powershell -Command "Unblock-File -Path \"%%F\""
)

REM Run the PowerShell script
powershell -ExecutionPolicy Bypass -File "%CD%\create_task.ps1"

```