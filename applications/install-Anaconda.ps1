<#
.SYNOPSIS
    Installs Anaconda

.LINK
    https://docs.anaconda.com/anaconda/install/silent-mode/
#>

<#

    software-unique configuration

#>
$softwareName = "Anaconda"

Function get-LatestVersionData {
    # Returns an object containing the current version and download URL for the software
    $VersionSite     = "https://www.anaconda.com/download#Downloads"
    $webPageFilePath = "C:\Users\$env:username\AppData\Local\Temp\$softwareName-site.html"    
    $webClient.DownloadFile($VersionSite, $webPageFilePath)

    $fileData = @((Get-Content -Path $webPageFilePath) | where {$_ -like "*Windows*"} | where {$_ -like "*anaconda.com/archive/Anacond*"})[-1]

    $hr = $fileData.Split("'")[1]
    $cv = $hr.split("-")[1]

    [PSCustomObject]@{
        currentVersion = $cv
        downloadUrl = $hr
    }
}

Function get-InstalledVersion {
    <#
        Returns the version data if the software is installed, and no value otherwise
    #>
    Get-ItemProperty HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\* | where {$_.DisplayName -like "*Anaconda*"} | foreach {$_.DisplayVersion}
}

Function get-upToDateStatus {
    (get-InstalledVersion) -like "*$((get-LatestVersionData).currentVersion)*"
}

Function install-LatestVersion {
    param($currentVersion, $downloadUrl)
    $webPageFilePath = "C:\Users\$env:username\AppData\Local\Temp\$softwareName-$currentVersion.exe"
    $logFilePath = "C:\Users\$env:username\AppData\Local\Temp\$softwareName-$currentVersion.log"
    $webClient.DownloadFile($downloadUrl, $webPageFilePath)

    Start-Process $webPageFilePath -Wait -ArgumentList @("/InstallationType=AllUsers", "/S")
}



<#

EXECUTION

#>

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
