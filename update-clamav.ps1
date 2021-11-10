#make the script executable as admin
param([switch]$Elevated)

function Test-Admin {
  $currentUser = New-Object Security.Principal.WindowsPrincipal $([Security.Principal.WindowsIdentity]::GetCurrent())
  $currentUser.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
}

if ((Test-Admin) -eq $false)  {
    if ($elevated) 
    {
        #tried to raise
    } 
    else {
        Start-Process powershell.exe -Verb RunAs -ArgumentList ('-noprofile -noexit -file "{0}" -elevated' -f ($myinvocation.MyCommand.Definition))
}

exit
}

#instance for check internet
$connected = [Activator]::CreateInstance([Type]::GetTypeFromCLSID([Guid]'{DCB00C01-570F-4A9B-8D69-199FDBA5723B}’)).IsConnectedToInternet

#check if the machine has internet access
if ($Connected -eq $True) {

    #uses TLS 1.2
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

    #variable environments
    $tempdest=(Get-Childitem -Path Env:TEMP).Value + "\ClamAV"
    $targetprogramfiles=$env:ProgramFiles

    #Check the presence of the temporary file, if not, create the directory temp\clamav
    If ((Test-Path $tempdest) -eq $False) {New-Item $tempdest -itemType Directory}

    #retrieve the cookie
    $Request = Invoke-WebRequest https://www.clamav.net/ -Method 'GET' -Headers @{
      "method"="GET"
      "authority"="www.clamav.net"
      "scheme"="https"
      "path"="/downloads/production/clamav-0.103.3.tar.gz"
      "sec-ch-ua"="`"Chromium`";v=`"92`", `" Not A;Brand`";v=`"99`", `"Google Chrome`";v=`"92`""
      "sec-ch-ua-mobile"="?0"
      "upgrade-insecure-requests"="1"
      "user-agent"="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/92.0.4515.159 Safari/537.36"
      "accept"="text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9"
      "sec-fetch-site"="none"
      "sec-fetch-mode"="navigate"
      "sec-fetch-user"="?1"
      "sec-fetch-dest"="document"
      "accept-encoding"="gzip, deflate, br"
      "accept-language"="fr-FR,fr;q=0.9,en-US;q=0.8,en;q=0.7"
    };

    #cookie parsing
    $cookie, $bin = $Request.Headers["Set-Cookie"] -split ";", 2
    $realcookie = "_ga=GA1.2.684229815.1629827059; _gid=GA1.2.657091150.1629827059; " + $cookie

    #I get all the HREF
    $r=iwr https://www.clamav.net/downloads#otherversions -UseBasicParsing -Headers @{
      "method"="GET"
      "authority"="www.clamav.net"
      "scheme"="https"
      "path"="/"
      "cache-control"="max-age=0"
      "sec-ch-ua"="`"Chromium`";v=`"92`", `" Not A;Brand`";v=`"99`", `"Google Chrome`";v=`"92`""
      "sec-ch-ua-mobile"="?0"
      "upgrade-insecure-requests"="1"
      "user-agent"="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/92.0.4515.159 Safari/537.36"
      "sec-fetch-site"="none"
      "sec-fetch-mode"="navigate"
      "sec-fetch-user"="?1"
      "sec-fetch-dest"="document"
      "accept-language"="fr-FR,fr;q=0.9,en-US;q=0.8,en;q=0.7"
      "cookie"=$realcookie
      }

    #I filter by retrieving the href with the extension ".zip".
    $href=($r.Links |?{$_.href -match "(win.x64.zip$)"}).href[0]

    #I form the link of dl the last version for windows 64 bit
    $links="https://www.clamav.net" + $href

    #create the .txt file of actualversion if it is not already created (1st time it is installed)
    If ((Test-Path "$tempdest\actualversion.txt") -eq $False) {
    
        #clamav installation

        #request for DL the .zip
        $Response=Invoke-WebRequest -Uri $links -Headers @{
        "method"="GET"
          "authority"="www.clamav.net"
          "scheme"="https"
          "path"="/downloads/production/clamav-0.103.3.tar.gz"
          "sec-ch-ua"="`"Chromium`";v=`"92`", `" Not A;Brand`";v=`"99`", `"Google Chrome`";v=`"92`""
          "sec-ch-ua-mobile"="?0"
          "upgrade-insecure-requests"="1"
          "user-agent"="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/92.0.4515.159 Safari/537.36"
          "accept"="text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9"
          "sec-fetch-site"="same-origin"
          "sec-fetch-mode"="navigate"
          "sec-fetch-user"="?1"
          "sec-fetch-dest"="document"
          "referer"="https://www.clamav.net/downloads"
          "accept-encoding"="gzip, deflate, br"
          "accept-language"="fr-FR,fr;q=0.9,en-US;q=0.8,en;q=0.7"
          "cookie"=$realcookie
          } -OutFile "$tempdest\ClamAV.zip"

        #unzip
        Expand-Archive -LiteralPath "$tempdest\ClamAV.zip" -DestinationPath "$tempdest\" 

        #know the name of the archive
        $name = (dir $tempdest).Name -match "win"

        #rename
        Rename-Item -Path "$tempdest\$name" -NewName "$tempdest\ClamAV"

        #copy of the archive
        Copy-Item –Path "$tempdest\ClamAV" –Destination $targetprogramfiles -Force -Recurse

        #creation of a .txt file the link used for DL
        New-Item "$tempdest\actualversion.txt" -type file

        #writing to the file
        ADD-content -path "$tempdest\actualversion.txt" -value $links

        #additional_actions, writing .conf
        Copy-Item -PAth "$targetprogramfiles\ClamAV\conf_examples\freshclam.conf.sample" -Destination "$targetprogramfiles\ClamAV\freshclam.conf" -Force -Recurse
        Copy-Item -PAth "$targetprogramfiles\ClamAV\conf_examples\clamd.conf.sample" -Destination "$targetprogramfiles\ClamAV\clamd.conf" -Force -Recurse

        #replace the "Example" in each .conf with "#Example
        $Filefresh =  "$targetprogramfiles\ClamAV\freshclam.conf"
        $Fileclamd =  "$targetprogramfiles\ClamAV\clamd.conf"
        $content = Get-Content $Filefresh | foreach { $_ -replace "Example","#Example" }
        Set-Content -Path "$Filefresh" -Value $Content
        $content = Get-Content $Fileclamd | foreach { $_ -replace "Example","#Example" }
        Set-Content -Path "$Fileclamd" -Value $Content

        #execute freshclam.exe
        start-process -FilePath "$targetprogramfiles\ClamAV\freshclam.exe" -Verb RunAs

        #deleting current files to save storage space
        Remove-Item "$tempdest\clamav.zip"
        Remove-Item "$tempdest\ClamAV" -Recurse
        }

    #if it is not the 1st installation
    If ((Test-Path "$tempdest\actualversion.txt") -eq $True) {
    
        $actualversion=Get-Content -Path "$tempdest\actualversion.txt"
        If (($actualversion -eq $links) -eq $False){

            #deleting old clamav files
            If ((Test-Path "$targetprogramfiles\ClamAV") -eq $True) {Remove-Item "$targetprogramfiles\ClamAV" -Recurse}

            #deleting actualversion
            Remove-Item "$tempdest\actualversion.txt" -Recurse

            #request for DL the .zip
            $Response=Invoke-WebRequest -Uri $links -Headers @{
            "method"="GET"
              "authority"="www.clamav.net"
              "scheme"="https"
              "path"="/downloads/production/clamav-0.103.3.tar.gz"
              "sec-ch-ua"="`"Chromium`";v=`"92`", `" Not A;Brand`";v=`"99`", `"Google Chrome`";v=`"92`""
              "sec-ch-ua-mobile"="?0"
              "upgrade-insecure-requests"="1"
              "user-agent"="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/92.0.4515.159 Safari/537.36"
              "accept"="text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9"
              "sec-fetch-site"="same-origin"
              "sec-fetch-mode"="navigate"
              "sec-fetch-user"="?1"
              "sec-fetch-dest"="document"
              "referer"="https://www.clamav.net/downloads"
              "accept-encoding"="gzip, deflate, br"
              "accept-language"="fr-FR,fr;q=0.9,en-US;q=0.8,en;q=0.7"
              "cookie"=$realcookie
              } -OutFile "$tempdest\ClamAV.zip"

            #unzip
            Expand-Archive -LiteralPath "$tempdest\ClamAV.zip" -DestinationPath "$tempdest\" 

            #know the name of the archive
            $name = (dir $tempdest).Name -match "win"

            #rename
            Rename-Item -Path "$tempdest\$name" -NewName "$tempdest\ClamAV"

            #copy of the archive
            Copy-Item –Path "$tempdest\ClamAV" –Destination $targetprogramfiles -Force -Recurse

            #creation of a .txt file the link used for DL
            New-Item "$tempdest\actualversion.txt" -type file

            #writing to the file
            ADD-content -path "$tempdest\actualversion.txt" -value $links

            #additional_actions, writing .conf
            Copy-Item -PAth "$targetprogramfiles\ClamAV\conf_examples\freshclam.conf.sample" -Destination "$targetprogramfiles\ClamAV\freshclam.conf" -Force -Recurse
            Copy-Item -PAth "$targetprogramfiles\ClamAV\conf_examples\clamd.conf.sample" -Destination "$targetprogramfiles\ClamAV\clamd.conf" -Force -Recurse

            #replace the "Example" in each .conf with "#Example
            $Filefresh =  "$targetprogramfiles\ClamAV\freshclam.conf"
            $Fileclamd =  "$targetprogramfiles\ClamAV\clamd.conf"
            $content = Get-Content $Filefresh | foreach { $_ -replace "Example","#Example" }
            Set-Content -Path "$Filefresh" -Value $Content
            $content = Get-Content $Fileclamd | foreach { $_ -replace "Example","#Example" }
            Set-Content -Path "$Fileclamd" -Value $Content

            #execute freshclam.exe
            start-process -FilePath "$targetprogramfiles\ClamAV\freshclam.exe" -Verb RunAs

            #supression des actuelles fichiers pour gagner du stockage
            Remove-Item "$tempdest\clamav.zip"
            Remove-Item "$tempdest\ClamAV" -Recurse
            }
    }
     
}else{
     
}

#stop process
stop-process -Id $PID
