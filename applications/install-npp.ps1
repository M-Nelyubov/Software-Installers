<#
.SYNOPSIS
    Installs Git for Windows

.LINK
https://notepad-plus-plus.org

#>

param([string]$installationPathRoot = "C:\temp\")
$webClient = (New-Object System.Net.WebClient)
$webPageFilePath = $installationPathRoot +"site.html"

#Fetch the latest version of Notepad++
$VersionSite = "https://notepad-plus-plus.org"
$webClient.DownloadFile($VersionSite, $webPageFilePath)

$fileData = (Get-Content -Path $webPageFilePath) -join "\r\n"
$startText = "Current Version ";
$endText = "</strong>"

$fileFromStartText = $fileData.Substring($fileData.IndexOf($startText) + $startText.Length)
$nppLatestVersion = $fileFromStartText.Substring(0, $fileFromStartText.IndexOf($endText))

#Check currently installed version in registry
$nppProd = Get-ItemProperty HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\* | where {$_.DisplayName -and $_.DisplayName.Contains("Notepad++")}

if(!$nppProd -or ($nppProd.DisplayVersion -ne $nppLatestVersion)){
    Write-Host "Installing NPP..."
    $nppInstallerFilePath = "$installationPathRoot\npp$nppLatestVersion.exe"

    #Download the executable to install the latest 64-bit version
    $nppDownloadLink = "https://github.com/notepad-plus-plus/notepad-plus-plus/releases/download/v" + $nppLatestVersion + "/npp." + $nppLatestVersion + ".Installer.x64.exe"
    $webClient.DownloadFile($nppDownloadLink, $nppInstallerFilePath)

    Start-Process -FilePath $nppInstallerFilePath -ArgumentList "/S"
}else{
    Write-Host "Latest version is already installed: Notepad++ - $nppLatestVersion" -ForegroundColor Green
}

# Refresh Environment Variable
$env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
