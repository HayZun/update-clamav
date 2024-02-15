@echo off
set "folder_path=C:\users\%USERNAME%\Downloads\update-clamav-main\update-clamav-main"

REM Unblock the files
forfiles /p "%folder_path%" /c "cmd /c powershell -Command Unblock-File -Path \"%~f0\"" 
REM Run the script to create the task
powershell -Command "Start-Process -Verb RunAs -FilePath \"%folder_path%\create_task.ps1\""
```