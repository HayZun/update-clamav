<#
###################################################################
Script Name : create_task.ps1                                                                                      
Version : 1.0                                                                                      
Author : Paul Durieux                                               
Email : paul.durieux@data-expertise.com                                           
###################################################################
#>

#Obtenir les droits d'administration
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
  Write-Warning "Vous n'avez pas les droits d'administration pour exécuter ce script !"
  Write-Warning "Relancez ce script en tant qu'administrateur !"
  Break
}

$currentUser = $env:USERNAME

# Chemin du script update-clamav.ps1
$pathInstallTaskClamav = "C:\Utilisateurs\$currentUser\Downloads\update-clamav-main\update-clamav.ps1"

# déplacer le script .\update-clamav.ps1 dans C:\Scripts
Copy-Item -Path $pathInstallTaskClamav -Destination "C:\Scripts\update-clamav.ps1" -Force

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
$taskprincipal = New-ScheduledTaskPrincipal -UserId $currentUser -RunLevel Highest

Register-ScheduledTask -TaskName $taskname -Action $taskaction -Trigger $tasktrigger -Description $taskdescription -Settings $tasksettings -Principal $taskprincipal

#Start the task now
Start-ScheduledTask -TaskName $taskname