<#
.SYNOPSIS
    Installs Git for Windows
.LINK
    https://desktop.github.com/
#>

param([string]$installationPathRoot = "C:\temp\")
$webClient = (New-Object System.Net.WebClient)
$webPageFilePath = $installationPathRoot +"site.html"

# Get version data of latest version
$VersionSite     = "https://github.com/desktop/desktop/tags"

$webClient = (New-Object System.Net.WebClient)
$webClient.DownloadFile($VersionSite, $webPageFilePath)

### Execution Section
$fileData = (Get-Content -Path $webPageFilePath) | where {$_.Contains("releases/tag/release-")} | where {-not $_.Contains("test")} | where {-not $_.Contains("beta")}   # -join "`r`n"
$fileData = $fileData[0].Replace("'",'"')
$latestGitDesktopVersion = ([xml]$fileData).h2.a."#text".Split("-")[-1]
### End of Execution Section



if((Test-Path ("~\AppData\Local\GitHubDesktop\GitHubDesktop.exe") -PathType Leaf) -and (Get-item "~\AppData\Local\GitHubDesktop\GitHubDesktop.exe").VersionInfo.FileVersion -eq $latestGitDesktopVersion){
    Write-Host "Latest version is already installed: git desktop - $latestGitDesktopVersion " -ForegroundColor Green
}else{
    $gitDesktopDownloadLink = 'https://central.github.com/deployments/desktop/desktop/latest/win32'
    $installationFilePath = $installationPathRoot+'gitDesktop.exe'
    $webClient.DownloadFile($gitDesktopDownloadLink, $installationFilePath)
    $latestGitDesktopVersion = (Get-Item -Path $installationFilePath).VersionInfo.FileVersion

    Write-Host "Installing Github Desktop $latestGitDesktopVersion..."
    Start-Process -Wait $installationFilePath -Argument "-s"
}

# Refresh Environment Variable
$env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
