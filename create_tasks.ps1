<#
###################################################################
Script Name : update-clamav.ps1                                                                                           
Version : 1.0                                                                                      
Author : Paul Durieux                                               
Email : paul.durieux@data-expertise.com                                           
###################################################################
#>

#déplacer le script update-clamav.ps1 dans le répertoire C:\Scripts\
Copy-Item -Path "./update-clamav.ps1" -Destination "C:\Scripts\update-clamav.ps1"

#créer le répertoire C:\temp\ClamAV
if (!($(Test-Path "C:\temp\ClamAV"))) {
  mkdir "C:\temp\ClamAV" -ea 0
}

#create task on task scheduler at logon
$taskname = "ClamAV Update"
$taskdescription = "Update ClamAV"
$taskaction = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "C:\Scripts\update-clamav.ps1"
$tasktrigger = New-ScheduledTaskTrigger -AtLogon
$tasksettings = New-ScheduledTaskSettingsSet -StartWhenAvailable
Register-ScheduledTask -TaskName $taskname -Action $taskaction -Trigger $tasktrigger -Description $taskdescription -Settings $tasksettings
