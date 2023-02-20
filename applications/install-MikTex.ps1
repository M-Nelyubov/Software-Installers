<#
.SYNOPSIS
    Installs MikTex

.LINK


#>

<#

    software-unique configuration

#>
$softwareName = "MiKTeX"

# Returns an object containing the current version and download URL for the software
Function get-LatestVersionData {
    $baseSite = "https://miktex.org"
    $VersionSite = "$baseSite/download"
    $webPageFilePath = "C:\Users\$env:username\AppData\Local\Temp\$softwareName-site.html"    
    $webClient.DownloadFile($VersionSite, $webPageFilePath)

    $startText = 'download/ctan/systems/win32/miktex/setup/windows-x64/basic-miktex'
    $fileData = @((Get-Content -Path $webPageFilePath) | where {$_.Contains($startText)})[0]

    $href = ([xml]$fileData).a.href

    $fullUrl = "$baseSite$href"

    [PSCustomObject]@{
        currentVersion = $href.split("/")[-1].Split("-")[-2]
        downloadUrl = $fullUrl
    }
}

Function get-InstalledVersion {
    <#
        Returns the version data if the software is installed, and no value otherwise
    #>
    Get-ItemProperty "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*" | where {$_.DisplayName -like ("$softwareName")} | foreach {$_.DisplayVersion}
}

Function get-upToDateStatus {
    (get-LatestVersionData).currentVersion -in (get-InstalledVersion) 
}

Function install-LatestVersion {
    param($currentVersion, $downloadUrl)
    $webPageFilePath = "C:\Users\$env:username\AppData\Local\Temp\$softwareName-$currentVersion.exe"
    $webClient.DownloadFile($downloadUrl, $webPageFilePath)

#    Start-Process -FilePath $webPageFilePath -ArgumentList "--unattended" -Wait
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
