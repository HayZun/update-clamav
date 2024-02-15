<#
###################################################################
Script Name : update-clamav.ps1                                                                                           
Version : 1.0                                                                                      
Author : Paul Durieux                                               
Email : paul.durieux@data-expertise.com                                           
###################################################################
#>

#tetser si la scanisette peut joindre internet 
try {

    $internet = $(Invoke-WebRequest -uri google.fr -UseBasicParsing).StatusCode
    if ($internet -ne 200) {
        exit
    }

}
catch { exit }

#rendre le script executable en tant qu'admin
function Test-Admin {
    $currentUser = New-Object Security.Principal.WindowsPrincipal $([Security.Principal.WindowsIdentity]::GetCurrent())
    $currentUser.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
}

if ((Test-Admin) -eq $false) {
    if ($elevated) {
        #essaye d'elever
    } 
    else {
        Start-Process powershell.exe -Verb RunAs -ArgumentList ('-noprofile -noexit -file "{0}" -elevated' -f ($myinvocation.MyCommand.Definition))
    }

    exit
}

#variable d'environnements
$tempdest = "C:\temp\ClamAV"
$targetprogramfiles = $env:ProgramFiles

#Verifier la precence du fichier temp
If ((Test-Path $tempdest) -eq $False) { New-Item $tempdest -itemType Directory }

#recuperer le cookie
$Request = Invoke-WebRequest https://www.clamav.net/ -Method 'GET' -Headers @{
    "method"                    = "GET"
    "authority"                 = "www.clamav.net"
    "scheme"                    = "https"
    "path"                      = "/downloads/production/clamav-0.103.3.tar.gz"
    "sec-ch-ua"                 = "`"Chromium`";v=`"92`", `" Not A;Brand`";v=`"99`", `"Google Chrome`";v=`"92`""
    "sec-ch-ua-mobile"          = "?0"
    "upgrade-insecure-requests" = "1"
    "user-agent"                = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/92.0.4515.159 Safari/537.36"
    "accept"                    = "text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9"
    "sec-fetch-site"            = "none"
    "sec-fetch-mode"            = "navigate"
    "sec-fetch-user"            = "?1"
    "sec-fetch-dest"            = "document"
    "accept-encoding"           = "gzip, deflate, br"
    "accept-language"           = "fr-FR,fr;q=0.9,en-US;q=0.8,en;q=0.7"
} -UseBasicParsing;

$cookie, $bin = $Request.Headers["Set-Cookie"] -split ";", 2
$realcookie = "_ga=GA1.2.684229815.1629827059; _gid=GA1.2.657091150.1629827059; " + $cookie

#je recupere tous les HREF
$r = iwr https://www.clamav.net/downloads#otherversions -UseBasicParsing -Headers @{
    "method"                    = "GET"
    "authority"                 = "www.clamav.net"
    "scheme"                    = "https"
    "path"                      = "/"
    "cache-control"             = "max-age=0"
    "sec-ch-ua"                 = "`"Chromium`";v=`"92`", `" Not A;Brand`";v=`"99`", `"Google Chrome`";v=`"92`""
    "sec-ch-ua-mobile"          = "?0"
    "upgrade-insecure-requests" = "1"
    "user-agent"                = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/92.0.4515.159 Safari/537.36"
    "sec-fetch-site"            = "none"
    "sec-fetch-mode"            = "navigate"
    "sec-fetch-user"            = "?1"
    "sec-fetch-dest"            = "document"
    "accept-language"           = "fr-FR,fr;q=0.9,en-US;q=0.8,en;q=0.7"
    "cookie"                    = $realcookie
}

#je filtre en recuperant le href avec comme extension ".zip"
$href = ($r.Links | ? { $_.href -match "(\/downloads\/production\/clamav-[0-9].[0-9]{0,}.[0-9].win.x64.zip(?!.*sig))" }).href[0]


#je forme le lien de dl la derniere version pour windows 64 bit
$links = "https://www.clamav.net" + $href

#actuelle version
If ((Test-Path "$tempdest\actualversion.txt") -eq $True) { $actualversion = Get-Content -Path "$tempdest\actualversion.txt" }

#si ce n'est pas la derniere version, il installe la derniere version
If (($actualversion -eq $links) -eq $False) {

    #stop des process clmad et freshclam
    $process = (Get-Process | Where-Object { $_.ProcessName -match "clamd|freshclam" }).ProcessName
    if ($process -ne $null) {
        foreach ($service in $process) {
            Stop-Process -Force -name $service
        }
    }

    #attendre la fermeture du process clamd
    Start-Sleep -Seconds 10

    #suppression des anciens fichiers de clamav
    If ((Test-Path "$tempdest\clamav.zip") -eq $True) { Remove-Item -Force -Path "$tempdest\clamav.zip" }
    If ((Test-Path "$tempdest\ClamAV") -eq $True) { Remove-Item -Force -Path "$tempdest\ClamAV" }
    If ((Test-Path "$targetprogramfiles\ClamAV") -eq $True) { Remove-Item -Force -Path "$targetprogramfiles\ClamAV" -Recurse }

    #suppresion du service clamd (if powerShell 6 => Remove-Service)
    $serviceClamd = Get-Service -Name "clamd"

    # si le service clamd existe, le supprimer
    if ($null -ne $serviceClamd) {
        sc.exe delete clamd
    }

    #request pour DL le .zip
    Invoke-WebRequest -Uri $links -Headers @{
        "method"                    = "GET"
        "authority"                 = "www.clamav.net"
        "scheme"                    = "https"
        "path"                      = "/downloads/production/clamav-0.103.3.tar.gz"
        "sec-ch-ua"                 = "`"Chromium`";v=`"92`", `" Not A;Brand`";v=`"99`", `"Google Chrome`";v=`"92`""
        "sec-ch-ua-mobile"          = "?0"
        "upgrade-insecure-requests" = "1"
        "user-agent"                = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/92.0.4515.159 Safari/537.36"
        "accept"                    = "text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9"
        "sec-fetch-site"            = "same-origin"
        "sec-fetch-mode"            = "navigate"
        "sec-fetch-user"            = "?1"
        "sec-fetch-dest"            = "document"
        "referer"                   = "https://www.clamav.net/downloads"
        "accept-encoding"           = "gzip, deflate, br"
        "accept-language"           = "fr-FR,fr;q=0.9,en-US;q=0.8,en;q=0.7"
        "cookie"                    = $realcookie
    } -OutFile "$tempdest\ClamAV.zip"

    #unzip
    Expand-Archive -LiteralPath "$tempdest\ClamAV.zip" -DestinationPath "$tempdest\ClamAV"

    $file = (ls "$tempdest\ClamAV\").Name
    
    #copie de l'archive
    Copy-Item -Path "$tempdest\ClamAV\$file" -Destination "$targetprogramfiles\ClamAV" -Force -Recurse

    #creation d'un fichier.txt le lien utilise pour DL
    If ((Test-Path "$tempdest\actualversion.txt") -eq $False) { New-Item "$tempdest\actualversion.txt" -type file }

    #suppression du fichier actualversion
    If ((Test-Path "$tempdest\actualversion.txt") -eq $True) { Remove-Item "$tempdest\actualversion.txt" }

    #ecriture dans le fichier
    ADD-content -path "$tempdest\actualversion.txt" -value $links

    #actions_supplemntaires, ecriture des .conf
    Copy-Item -PAth "$targetprogramfiles\ClamAV\conf_examples\freshclam.conf.sample" -Destination "$targetprogramfiles\ClamAV\freshclam.conf" -Force -Recurse
    Copy-Item -PAth "$targetprogramfiles\ClamAV\conf_examples\clamd.conf.sample" -Destination "$targetprogramfiles\ClamAV\clamd.conf" -Force -Recurse

    #remplacez le "Example" de chaque .conf par "#Example"
    $Filefresh = "$targetprogramfiles\ClamAV\freshclam.conf"
    $Fileclamd = "$targetprogramfiles\ClamAV\clamd.conf"
    $content = Get-Content $Filefresh | foreach { $_ -replace "Example", "#Example" }
    Set-Content -Path "$Filefresh" -Value $Content
    $content = Get-Content $Fileclamd | foreach { $_ -replace "Example", "#Example" }
    Set-Content -Path "$Fileclamd" -Value $Content
    $content = Get-Content $Fileclamd | foreach { $_ -replace "localhost", "127.0.0.1" }
    Set-Content -Path "$Fileclamd" -Value $Content

    #supression des actuelles fichiers pour gagner du stockage
    Remove-Item "$tempdest\clamav.zip"
    Remove-Item "$tempdest\ClamAV" -Recurse

    # Installation de clamd comme démon
    Start-Process -FilePath "$targetprogramfiles\ClamAV\clamd.exe" -ArgumentList "--install" -Verb RunAs -Wait

    # Installation de freshclam
    Start-process -FilePath "$targetprogramfiles\ClamAV\freshclam.exe" -Wait

    # Modifier le service clamd pour qu'il demarre automatiquement au demarrage
    Set-Service -Name "clamd" -StartupType Automatic

    # Démarrer le service clamd
    Start-Service -Name "clamd"
}

#stop process
stop-process -Id $PID
