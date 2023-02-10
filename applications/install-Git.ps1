<#
.SYNOPSIS
    Installs Git for Windows

.LINK
https://github.com/git-for-windows/build-extra/blob/main/installer/install.iss#L105

.LINK
https://silentinstallhq.com/git-silent-install-how-to-guide/
.LINK
https://github.com/git-for-windows/git-for-windows.github.io
.LINK
https://gitforwindows.org/
#>


<#

    software-unique configuration

#>
$softwareName = "GitForWindows"

Function get-LatestVersionData {
    # Returns an object containing the current version and download URL for the software
    $VersionSite     = "https://gitforwindows.org/"
    $webPageFilePath = "C:\Users\$env:username\AppData\Local\Temp\$softwareName-site.html"    
    $webClient.DownloadFile($VersionSite, $webPageFilePath)
    $fileData = (Get-Content -Path $webPageFilePath) | where {$_.Contains("/releases/tag/v")}
    $fileData = [xml]@($fileData)[0]
    
    $cv = $fileData.div.a."#text".Split(" ")[1]


    [PSCustomObject]@{
        currentVersion = $cv
        downloadUrl = "https://github.com/git-for-windows/git/releases/download/v$cv.windows.1/Git-$cv-64-bit.exe"
    }
}

Function get-InstalledVersion {
    <#
        Returns the version data if the software is installed, and no value otherwise
    #>
    Get-ItemProperty HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\* | where {$_.DisplayName -and $_.DisplayName.Contains("Git")} | foreach {$_.DisplayVersion}
}

Function get-upToDateStatus {
    (get-LatestVersionData).currentVersion -in (get-InstalledVersion) 
}

Function install-LatestVersion {
    param($currentVersion, $downloadUrl)
    $webPageFilePath = "C:\Users\$env:username\AppData\Local\Temp\$softwareName-$currentVersion.exe"
    $logFilePath = "C:\Users\$env:username\AppData\Local\Temp\$softwareName-$currentVersion.log"
    $webClient.DownloadFile($downloadUrl, $webPageFilePath)
    Start-Process -Wait $webPageFilePath -ArgumentList @('/VERYSILENT', '/COMPONENTS="icons,ext\reg\shellhere,assoc,assoc_sh"')
}



<#

EXECUTION

#>
Function main {
    $webClient = (New-Object System.Net.WebClient)
    $latestData = get-LatestVersionData
    $currentVersion = $latestData.currentVersion

    if(get-upToDateStatus){
        Write-Host -ForegroundColor Green "Latest version is already installed: $softwareName - $currentVersion"
        exit
    }

    Write-Host "Installing $softwareName $currentVersion"
    install-LatestVersion -currentVersion $currentVersion -downloadUrl $latestData.downloadUrl

    # Verify installation was successful
    if(get-upToDateStatus){
        Write-Host -ForegroundColor Green "Latest version has been installed: $softwareName - $currentVersion"

        # Refresh Environment Variable after the install
        $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
    } else {
        Write-Error "Failed to install latest version of $softwareName - $currentVersion"
    }
}

if($MyInvocation.InvocationName -ne ".") {main}
