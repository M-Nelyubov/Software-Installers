<#
.SYNOPSIS
    Installs Node.js

.LINK
https://nodejs.org/en/

#>

<#

    software-unique configuration

#>
$softwareName = "Node.js"

Function get-LatestVersionData {
    # Returns an object containing the current version and download URL for the software
    $VersionSite     = "https://nodejs.org/en/"
    $content = Invoke-WebRequest -UseBasicParsing -Uri $VersionSite
    $downloadBlock = @($content.Links | where {$_ -like "*LTS*"})[0]
    $cv = $downloadBlock."data-version".Replace("v","")
    


    [PSCustomObject]@{
        currentVersion = $cv
        downloadUrl = "https://nodejs.org/dist/v$cv/node-v$cv-x64.msi"
    }
}

Function get-InstalledVersion {
    <#
        Returns the version data if the software is installed, and no value otherwise
    #>
    Get-ItemProperty HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\* | where {$_.DisplayName -and $_.DisplayName.Contains("Node")} | foreach {$_.DisplayVersion}
}

Function get-upToDateStatus {
    (get-LatestVersionData).currentVersion -in (get-InstalledVersion) 
}

Function install-LatestVersion {
    param($currentVersion, $downloadUrl)
    $webPageFilePath = "C:\Users\$env:username\AppData\Local\Temp\$softwareName-$currentVersion.msi"
    $logFilePath = "C:\Users\$env:username\AppData\Local\Temp\$softwareName-$currentVersion.log"
    $webClient.DownloadFile($downloadUrl, $webPageFilePath)

    start-process msiexec.exe -Wait -ArgumentList @("/passive", "/log", "$logFilePath.log", "/package", $webPageFilePath)
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
