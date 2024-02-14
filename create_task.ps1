<#
###################################################################
Script Name : create_task.ps1                                                                                      
Version : 1.0                                                                                      
Author : Paul Durieux                                               
Email : paul.durieux@data-expertise.com                                           
###################################################################
#>

Function Check-RunAsAdministrator() {
  #Get current user context
  $CurrentUser = New-Object Security.Principal.WindowsPrincipal $([Security.Principal.WindowsIdentity]::GetCurrent())
  
  #Check user is running the script is member of Administrator Group
  if ($CurrentUser.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)) {
    Write-host "Script is running with Administrator privileges!"
  }
  else {
    #Create a new Elevated process to Start PowerShell
    $ElevatedProcess = New-Object System.Diagnostics.ProcessStartInfo "PowerShell";
 
    # Specify the current script path and name as a parameter
    $ElevatedProcess.Arguments = "& '" + $script:MyInvocation.MyCommand.Path + "'"
 
    #Set the Process to elevated
    $ElevatedProcess.Verb = "runas"
 
    #Start the new elevated process
    [System.Diagnostics.Process]::Start($ElevatedProcess)
 
    #Exit from the current, unelevated, process
    Exit
 
  }
}
 
#Check Script is running with Elevated Privileges
Check-RunAsAdministrator

# Chemin du script update-clamav.ps1
$currentUser = $env:USERNAME
$pathInstallTaskClamav = "C:\Users\$currentUser\Downloads\update-clamav-main\update-clamav-main\update-clamav.ps1"

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

#Vérifier que la tâche planifiée a bien été créée
$task = Get-ScheduledTask -TaskName $taskname

if ($task) {
  Write-Host "Scheduled Task $taskname created successfully"
}
else {
  Write-Host "Failed to create Scheduled Task $taskname"
}

Start-Sleep -Seconds 5

#Stop the Process
Stop-Process -Id $PID
```