# Installation de ClamAV

## Prérequis

Avoir l'éxécution de scripts activé sur le système :

`Set-ExecutionPolicy -ExecutionPolicy Unrestricted`

## Instructions

1. Téléchargez et extrayez l'archive clamav_install.zip.
2. Ouvrir un powershell en tant qu'admin et exécutez la commande :
`Get-childitem "C:\users\$env:USERNAME\Downloads\update-clamav-main\update-clamav-main" | unblock-file`
2. Recherchez le script install.ps1 dans le répertoire extrait.
3. Faites un clic droit sur install.ps1 et sélectionnez "Exécuter avec Powershell".
