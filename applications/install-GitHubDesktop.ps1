<#
.SYNOPSIS
    Installs GitHub Desktop
.LINK
    https://desktop.github.com/
#>

<#

    software-unique configuration

#>
$softwareName = "GitHub Desktop"

Function get-LatestVersionData {
    # Returns an object containing the current version and download URL for the software
    $VersionSite     = "https://github.com/desktop/desktop/tags"
    $webPageFilePath = "C:\Users\$env:username\AppData\Local\Temp\$softwareName-site.html"    
    $webClient.DownloadFile($VersionSite, $webPageFilePath)
    $fileData = (Get-Content -Path $webPageFilePath) | where {$_.Contains("releases/tag/release-")} | where {-not $_.Contains("test")} | where {-not $_.Contains("beta")}
    $fileData = @($fileData)[0].Replace("'",'"')  # Ensure fileData is parsed as an array and then take that array's first element
    $cv = ([xml]$fileData).h2.a."#text".Split("-")[-1]

    [PSCustomObject]@{
        currentVersion = $cv
        downloadUrl = 'https://central.github.com/deployments/desktop/desktop/latest/win32'
    }
}

Function get-InstalledVersion {
    <#
        Returns the version data if the software is installed, and no value otherwise
    #>
    "~\AppData\Local\GitHubDesktop\GitHubDesktop.exe" | where {Test-Path $_ -PathType Leaf} | foreach {(Get-Item $_).VersionInfo.FileVersion}
}

Function get-upToDateStatus {
    (get-LatestVersionData).currentVersion -in (get-InstalledVersion) 
}

Function install-LatestVersion {
    param($currentVersion, $downloadUrl)
    $webPageFilePath = "C:\Users\$env:username\AppData\Local\Temp\$softwareName-$currentVersion.exe"
    $logFilePath = "C:\Users\$env:username\AppData\Local\Temp\$softwareName-$currentVersion.log"
    $webClient.DownloadFile($downloadUrl, $webPageFilePath)
    Start-Process -Wait $webPageFilePath -Argument "-s"

    # Sleep for a second to avoid false negative error
    Start-Sleep 1
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
