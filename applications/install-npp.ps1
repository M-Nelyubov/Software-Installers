<#
.SYNOPSIS
    Installs Notepad++

.LINK
    https://notepad-plus-plus.org

#>

<#

    software-unique configuration

#>
$softwareName = "Notepad++"

# Returns an object containing the current version and download URL for the software
Function get-LatestVersionData {
    $VersionSite     = "https://python.org/downloads"
    $webPageFilePath = "C:\Users\$env:username\AppData\Local\Temp\npp-site.html"
    
    $webClient.DownloadFile($VersionSite, $webPageFilePath)
    
    $VersionSite = "https://notepad-plus-plus.org"
    $webClient.DownloadFile($VersionSite, $webPageFilePath)

    $fileData = (Get-Content -Path $webPageFilePath) -join "\r\n"
    $startText = "Current Version ";
    $endText = "</strong>"

    $fileFromStartText = $fileData.Substring($fileData.IndexOf($startText) + $startText.Length)
    $nppLatestVersion = $fileFromStartText.Substring(0, $fileFromStartText.IndexOf($endText))

    


    [PSCustomObject]@{
        currentVersion = $nppLatestVersion
        downloadUrl = "https://github.com/notepad-plus-plus/notepad-plus-plus/releases/download/v" + $nppLatestVersion + "/npp." + $nppLatestVersion + ".Installer.x64.exe"
    }
}

Function get-InstalledVersion {
    <#
        Returns the version data if the software is installed, and no value otherwise
    #>
    Get-ItemProperty HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\* | where {$_.DisplayName -and $_.DisplayName.Contains("Notepad++")} | foreach {$_.DisplayVersion}
}

Function get-upToDateStatus {
    (get-LatestVersionData).currentVersion -in (get-InstalledVersion) 
}

Function install-LatestVersion {
    param($currentVersion, $downloadUrl)
    $webPageFilePath = "C:\Users\$env:username\AppData\Local\Temp\npp-$currentVersion.exe"
    $webClient.DownloadFile($downloadUrl, $webPageFilePath)

    Start-Process -FilePath $webPageFilePath -ArgumentList "/S" -Wait
}



<#

EXECUTION

#>

$webClient = (New-Object System.Net.WebClient)
$latestData = get-LatestVersionData

if(get-upToDateStatus){
    Write-Host -ForegroundColor Green "Latest version is already installed: $softwareName - $($latestData.currentVersion)"
    exit
}

Write-Host "Installing $softwareName $($latestData.currentVersion)"
install-LatestVersion -currentVersion $latestData.currentVersion -downloadUrl $latestData.downloadUrl

# Verify installation was successful
if(get-upToDateStatus){
    Write-Host -ForegroundColor Green "Latest version has been installed: $softwareName - $currentVersion"

	# Refresh Environment Variable after the install
	$env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
} else {
    Write-Error "Failed to install latest version of $softwareName - $currentVersion"
}
