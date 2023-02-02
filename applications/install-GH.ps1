<#
.SYNOPSIS
    Installs GH

.LINK
    https://cli.github.com/
#>

<#

    software-unique configuration

#>
$softwareName = "GH"

Function get-LatestVersionData {
    # Returns an object containing the current version and download URL for the software
    $VersionSite     = "https://cli.github.com/"
    $webPageFilePath = "C:\Users\$env:username\AppData\Local\Temp\$softwareName-site.html"    
    $webClient.DownloadFile($VersionSite, $webPageFilePath)

    $startText = '//github.com/cli/cli/releases/download/v'
    $fileData = @((Get-Content -Path $webPageFilePath) | foreach {$_.Replace("'",'"')} | where {$_.Contains($startText)} | where {$_.Contains("windows")})[0]

    $hr = ([xml]$fileData).a.href
    $cv = $hr.Split("/")[-1].split("_")[1]

    [PSCustomObject]@{
        currentVersion = $cv
        downloadUrl = $hr
    }
}

Function get-InstalledVersion {
    <#
        Returns the version data if the software is installed, and no value otherwise
    #>
    Get-ItemProperty HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\* | where {$_.DisplayName -like "GitHub CLI"} | foreach {$_.DisplayVersion}
}

Function get-upToDateStatus {
    (get-LatestVersionData).currentVersion -in (get-InstalledVersion) 
}

Function install-LatestVersion {
    param($currentVersion, $downloadUrl)
    $webPageFilePath = "C:\Users\$env:username\AppData\Local\Temp\$softwareName-$currentVersion.msi"
    $logFilePath = "C:\Users\$env:username\AppData\Local\Temp\$softwareName-$currentVersion.log"
    $webClient.DownloadFile($downloadUrl, $webPageFilePath)

    Start-Process msiexec.exe -Wait -ArgumentList @("/passive", "/log", "$logFilePath.log", "/package", $webPageFilePath)
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


# TODO: run `gh auth login`
