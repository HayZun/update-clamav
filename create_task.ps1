<#
###################################################################
Script Name : create_task.ps1                                                                                      
Version : 1.0                                                                                      
Author : Paul Durieux                                               
Email : paul.durieux@data-expertise.com                                           
###################################################################
#>

#déplacer le script .\update-clamav.ps1 dans C:\Scripts
Copy-Item -Path .\update-clamav.ps1 -Destination "C:\Scripts\update-clamav.ps1" -Force

#créer le répertoire C:\temp\ClamAV
if (!($(Test-Path "C:\temp\ClamAV"))) {
  mkdir "C:\temp\ClamAV" -ea 0
}

# Créer la tâche planifiée pour mettre à jour ClamAV
$taskname = "ClamAV Update"
$taskdescription = "Update ClamAV"
$taskaction = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "C:\Scripts\update-clamav.ps1"
$tasktrigger = New-ScheduledTaskTrigger -Daily -At 8am
$tasksettings = New-ScheduledTaskSettingsSet -StartWhenAvailable
$taskprincipal = New-ScheduledTaskPrincipal -UserId "scanisette" -RunLevel Highest

Register-ScheduledTask -TaskName $taskname -Action $taskaction -Trigger $tasktrigger -Description $taskdescription -Settings $tasksettings -Principal $taskprincipal

#Start the task now
Start-ScheduledTask -TaskName $taskname