<#
.SYNOPSIS
    Installs CMake
#>

<#

    software-unique configuration
    
#>
$softwareName = "CMake"

# Returns an object containing the current version and download URL for the software
Function get-LatestVersionData {
    $VersionSite = "https://cmake.org/download/"
    $response = Invoke-WebRequest -UseBasicParsing -Uri $VersionSite

    $fileData = $response.Content

    $links = $fileData.Split("`r`n") | where {$_.Contains("windows-x86_64")} | where {$_.Contains("msi")}
    $downloadPath = ([xml]$links[0]).td.a.href

    [PSCustomObject]@{
        currentVersion = $downloadPath.Split("/")[-2].Substring(1).Split("-")[0]
        downloadUrl = $downloadPath
    }
}

Function get-InstalledVersion {
    <#
        Returns the version data if the software is installed, and no value otherwise
    #>
    Get-ItemProperty HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\* | where {$_.DisplayName -like "cmake"} | foreach {$_.DisplayVersion}
}

Function get-upToDateStatus {
    (get-LatestVersionData).currentVersion -in (get-InstalledVersion) -and ($env:Path -like "*$softwareName*")
}

Function install-LatestVersion {
    param($currentVersion, $downloadUrl)
    $webPageFilePath = "C:\Users\$env:username\AppData\Local\Temp\$softwareName-$currentVersion.msi"
    $logFilePath = "C:\Users\$env:username\AppData\Local\Temp\$softwareName-$currentVersion.log"
    $webClient.DownloadFile($downloadUrl, $webPageFilePath)

    Start-Process msiexec.exe -Wait -ArgumentList @("/passive", "ADD_CMAKE_TO_PATH=System", "/log", "$logFilePath.log", "/package", $webPageFilePath)
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

# Refresh Environment Variable after the install
$env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")

# Verify installation was successful
if(get-upToDateStatus){
    Write-Host -ForegroundColor Green "Latest version has been installed: $softwareName - $currentVersion"
} else {
    Write-Error "Failed to install latest version of $softwareName - $currentVersion"
}
