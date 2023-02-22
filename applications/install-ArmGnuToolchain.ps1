<#
.SYNOPSIS
    Installs the ARM GNU Toolchain for the Remote Stethoscope project

.LINK
    https://developer.arm.com/downloads/-/arm-gnu-toolchain-downloads
.LINK
    https://datasheets.raspberrypi.com/pico/getting-started-with-pico.pdf
.LINK
    https://github.com/ArmDeveloperEcosystem/microphone-library-for-pico#building
#>

<#

    software-unique configuration
    
#>
$softwareName = "Arm GNU Toolchain"

# Returns an object containing the current version and download URL for the software
Function get-LatestVersionData {
    $baseSite = "https://developer.arm.com"
    $VersionSite = "$baseSite/downloads/-/arm-gnu-toolchain-downloads"
    $webPageFilePath = "C:\Users\$env:username\AppData\Local\Temp\$softwareName-site.html"    
    $webClient.DownloadFile($VersionSite, $webPageFilePath)

    $fileData = (Get-Content -Path $webPageFilePath) | where {$_ -like "*arm-none-eabi*"} | where {$_ -like "*.exe*"}

    $href = ([xml]$fileData[0]).li.nobr.a.href

    $fullUrl = "$baseSite$href"

    [PSCustomObject]@{
        currentVersion = $href.split("/")[-1].Split("-")[3]
        downloadUrl = $fullUrl
    }
}

Function get-InstalledVersion {
    <#
        Returns the version data if the software is installed, and no value otherwise
    #>
    @("C:\Program Files (x86)\Arm GNU Toolchain arm-none-eabi" | where {Test-Path $_} | ls | sort -Property LastWriteTime | foreach {$_.Name})[0]
}

Function get-upToDateStatus {
    (get-LatestVersionData).currentVersion -in (get-InstalledVersion).Trim().Replace(" ",".")
}

Function install-LatestVersion {
    param($currentVersion, $downloadUrl)
    $webPageFilePath = "C:\Users\$env:username\AppData\Local\Temp\$softwareName-$currentVersion.exe"
    $webClient.DownloadFile($downloadUrl, $webPageFilePath)

    Start-Process -FilePath $webPageFilePath -ArgumentList "/S" -Wait
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
