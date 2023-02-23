<#
.SYNOPSIS
    Installs the desktop development with C++ toolkit for Visual Studio 2022

.LINK
    https://learn.microsoft.com/en-us/visualstudio/install/workload-component-id-vs-build-tools?view=vs-2022#desktop-development-with-c

.LINK
    https://learn.microsoft.com/en-us/answers/questions/192162/visual-studio-build-tools-silent-install

.LINK
    https://visualstudio.microsoft.com/downloads/#build-tools-for-visual-studio-2022

.LINK
    https://datasheets.raspberrypi.com/pico/getting-started-with-pico.pdf

.LINK
    https://github.com/ArmDeveloperEcosystem/microphone-library-for-pico#building
#>

<#

    software-unique configuration
    
#>
$softwareName = "Visual Studio 2022 Toolkit - Desktop Development with C++ on Windows 11"
$requiredPackages = @("Microsoft.VisualStudio.Workload.VCTools", "Microsoft.VisualStudio.Component.Windows11SDK.22000")

# Returns an object containing the current version and download URL for the software
Function get-LatestVersionData {
    $response = Invoke-WebRequest -UseBasicParsing -Uri "https://visualstudio.microsoft.com/downloads/#build-tools-for-visual-studio-2022"
    
    $fileData = $response.Content
    $downloadLink = $fileData.Split("`n") | where {$_.Contains("vs_BuildTools")} | where {$_.Contains("href")}

    [PSCustomObject]@{
        currentVersion = "-"
        downloadUrl = $downloadLink.split("`"")[1].Trim()
    }
}

Function get-upToDateStatus {
    Install-Module VSSetup -Scope CurrentUser -Force
    $installedPackages = Get-VSSetupInstance | foreach {$_.Packages.Id}
    -not ($requiredPackages | where {-not ($_ -in $installedPackages)})
}

Function install-LatestVersion {
    param($currentVersion, $downloadUrl)
    $webPageFilePath = "C:\Users\$env:username\AppData\Local\Temp\$softwareName-$currentVersion.exe"
    $logFilePath = "C:\Users\$env:username\AppData\Local\Temp\$softwareName-$currentVersion.log"
    $webClient.DownloadFile($downloadUrl, $webPageFilePath)
    $arguments = @("--quiet", $requiredPackages | foreach {"--add $_"}) -join " "

    Start-Process $webPageFilePath -ArgumentList $arguments -Wait
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
