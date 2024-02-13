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

#create task on task scheduler at logon and éxécuter le script même si l'utilisateur n'est pas connecté 1 fois par jour à 8h
$taskname = "ClamAV Update"
$taskdescription = "Update ClamAV"
$taskaction = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "C:\Scripts\update-clamav.ps1"
$tasktrigger = New-ScheduledTaskTrigge -AtLogOn -Daily -DaysInterval 1 -At 8am
$tasksettings = New-ScheduledTaskSettingsSet -StartWhenAvailable
Register-ScheduledTask -TaskName $taskname -Action $taskaction -Trigger $tasktrigger -Description $taskdescription -Settings $tasksettings


#start the task now
#Start-ScheduledTask -TaskName $taskname