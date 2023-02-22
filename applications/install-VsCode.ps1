<#
.SYNOPSIS
    Installs Visual Studio Code
#>

<#

    software-unique configuration

#>
$softwareName = "Visual Studio Code"

Function get-LatestVersionData {
    # Returns an object containing the current version and download URL for the software
    $VersionSite     = "https://code.visualstudio.com/updates/"
    $webPageFilePath = "C:\Users\$env:username\AppData\Local\Temp\$softwareName-site.html"    
    $webClient.DownloadFile($VersionSite, $webPageFilePath)


    $startText = '.com/'
    $endText   = '/'
    $fileData = (Get-Content -Path $webPageFilePath) -join "`n"
    $fileData = $fileData.Replace("'",'"')

    ### TEST SEGMENT
    # $versionIDX = $fileData.IndexOf("5.17")
    # $fileData.Substring($versionIDX-30, 60)
    # exit
    ### END OF TEST SEGMENT


    ### Execution Section
    $fileData = $fileData.Substring($fileData.IndexOf("Downloads:"))
    $downloadBlob = @($fileData.Split("`n") | where {$_.Contains($startText)})[0].Split(" ") | where {$_.Contains("href")} | foreach {"<a $_"}
    $hr = ([xml]$downloadBlob[0]).a.href
    $cv = $hr.split("/")[3]

    [PSCustomObject]@{
        currentVersion = $cv
        downloadUrl = $hr
    }
}

Function get-InstalledVersion {
    <#
        Returns the version data if the software is installed, and no value otherwise
    #>
    Get-ItemProperty HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\* | where {$_.DisplayName -like "*$softwareName*"} | foreach {$_.DisplayVersion}
}

Function get-upToDateStatus {
    (get-LatestVersionData).currentVersion -in (get-InstalledVersion) 
}

Function install-LatestVersion {
    param($currentVersion, $downloadUrl)
    $webPageFilePath = "C:\Users\$env:username\AppData\Local\Temp\$softwareName-$currentVersion.exe"
    $logFilePath = "C:\Users\$env:username\AppData\Local\Temp\$softwareName-$currentVersion.log"
    $webClient.DownloadFile($downloadUrl, $webPageFilePath)
    
    Start-Process -FilePath $webPageFilePath -ArgumentList @("/VERYSILENT", "/NORESTART")
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
