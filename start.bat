@REM @echo off
@REM set "folder_path=C:\users\%USERNAME%\Downloads\update-clamav-main\update-clamav-main"

@REM cmd /c powershell -Command Unblock-File -Path "%folder_path%\update-clamav.ps1"
@REM cmd /c powershell -Command Unblock-File -Path "%folder_path%\create_task.ps1"



@REM REM Run the script to create the task
@REM REM powershell -Command "Start-Process -Verb RunAs -FilePath \"%folder_path%\create_task.ps1\""

@echo off
set "folder_path=C:\users\%USERNAME%\Downloads\update-clamav-main\update-clamav-main"

for %%F in ("%folder_path%\*.ps1") do (
    cmd /c powershell -Command "Unblock-File -Path \"%%F\""
)

```