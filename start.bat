@echo off
pause
REM Unblock all files in the folder
for %%F in ("%CD%\*.ps1") do (
    cmd /c powershell -Command "Unblock-File -Path \"%%F\""
)
pause
REM Run the PowerShell script
powershell -ExecutionPolicy Bypass -File "%CD%\create_task.ps1"

```