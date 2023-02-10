<#
.SYNOPSIS
    Installs the latest version of Python

#>


<#

    software-unique configuration

#>
$softwareName = "Python"

# Returns an object containing the current version and download URL for the software
Function get-LatestVersionData {
    $VersionSite     = "https://python.org/downloads"
    $webPageFilePath = "C:\Users\$env:username\AppData\Local\Temp\python-site.html"
    
    $webClient.DownloadFile($VersionSite, $webPageFilePath)
    
    $startText = '<span class="release-version">';
    
    
    $fileData = @((Get-Content -Path $webPageFilePath) | Where-Object {$_.Contains($startText)} | Where-Object {-not ($_.Contains("Python version"))})[0]
    $currentMajor = ([xml]$fileData).span."#text"
    
    $fileData = @((Get-Content -Path $webPageFilePath))
    $minorReleaseData = $fileData | where {$_.COntains($currentMajor)} | where {$_.Contains(".exe")} | foreach {([xml] $_).a}

    [PSCustomObject]@{
        currentVersion = $minorReleaseData."#text".Split(" ")[-1]
        downloadUrl = $minorReleaseData.href
    }
}

Function get-InstalledVersion {
    <#
        Returns the version data if the software is installed, and no value otherwise
    #>
    "HKLM:\SOFTWARE\Python\PythonCore\" | where {Test-Path $_} | foreach {ls $_} | foreach {$_.GetValue('Version')}
}

Function get-upToDateStatus {
    (get-LatestVersionData).currentVersion -in (get-InstalledVersion) 
}

Function install-LatestVersion {
    param($currentVersion, $downloadUrl)

    # Download the .exe for the latest version of Python
    $installerPath = "C:\Users\$env:username\AppData\Local\Temp\python-$currentVersion.exe"
    $webClient.DownloadFile($downloadUrl, $installerPath)

    # Silently install the downloaded Python exe
    # Arguments from: https://silentinstallhq.com/python-3-10-silent-install-how-to-guide/
    Start-Process -FilePath $installerPath -ArgumentList "/quiet InstallAllUsers=1 PrependPath=1" -Wait

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
