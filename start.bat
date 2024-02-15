@echo off

REM Set the folder path
set "folder_path=C:\users\%USERNAME%\Downloads\update-clamav-main\update-clamav-main"

REM Unblock all files in the folder
for %%F in ("%folder_path%\*.ps1") do (
    cmd /c powershell -Command "Unblock-File -Path \"%%F\""
)

REM Run the PowerShell script
powershell -ExecutionPolicy Bypass -File "%folder_path%\create_task.ps1"

```