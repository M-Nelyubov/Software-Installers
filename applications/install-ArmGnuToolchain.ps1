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
$installationDir = "C:\Program Files (x86)\Arm GNU Toolchain arm-none-eabi"

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
    @($installationDir | where {Test-Path $_} | ls | sort -Property LastWriteTime | foreach {$_.Name})[0]
}

Function get-upToDateStatus {
    ((get-LatestVersionData).currentVersion -in (get-InstalledVersion).Trim().Replace(" ",".")) -and ($env:Path -like "*$installationDir*")
}

Function install-LatestVersion {
    param($currentVersion, $downloadUrl)
    $webPageFilePath = "C:\Users\$env:username\AppData\Local\Temp\$softwareName-$currentVersion.exe"
    $webClient.DownloadFile($downloadUrl, $webPageFilePath)

    Start-Process -FilePath $webPageFilePath -ArgumentList "/S" -Wait

    # Add path to environment variable
    $basePath = get-InstalledVersion
    $newAddition = ";$basePath\bin"
    $prior = [Environment]::GetEnvironmentVariable('Path')
    if(-not ($newAddition -in $prior)){
        # Remove any old installs from the environment variable
        $allVersionsRoot = $installationDir
        $prior = @($prior.Split(";") | where {-not ($allVersionsRoot -in $_)}) -join ";"

        # save new environment path
        [Environment]::SetEnvironmentVariable('Path', $prior + $newAddition, 'Machine')
    
    }
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
