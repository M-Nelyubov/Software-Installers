<#
.SYNOPSIS
    Installs Git for Windows

.LINK
https://github.com/git-for-windows/build-extra/blob/main/installer/install.iss#L105

.LINK
https://silentinstallhq.com/git-silent-install-how-to-guide/
.LINK
https://github.com/git-for-windows/git-for-windows.github.io
.LINK
https://gitforwindows.org/
#>

param([string]$installationPathRoot = "C:\temp\")
$webClient = (New-Object System.Net.WebClient)
$webPageFilePath = $installationPathRoot +"site.html"


if(-not (Test-Path -Path $installationPathRoot -PathType Container)){
    Write-Host "Creating $installationPathRoot"
    mkdir $installationPathRoot
}



#Fetch latest version of git 
$VersionSite = "https://gitforwindows.org/"

$webClient.DownloadFile($VersionSite, $webPageFilePath)
$fileData = (Get-Content -Path $webPageFilePath) | where {$_.Contains("/releases/tag/v")}
if($fileData.GetType().BaseType.Name -eq "Array"){
    $fileData = $fileData[0]
}
$fileData = $fileData.Substring($fileData.IndexOf("g/v")+ 3)
$fileData = $fileData.Substring(0, $fileData.IndexOf('.windows.'))

$gitVersion = $fileData

#Construct git download URL
$gitDownloadLink = "https://github.com/git-for-windows/git/releases/download/v$gitVersion.windows.1/Git-$gitVersion-64-bit.exe"

#$wmiProductObject = Get-WmiObject Win32_Product
#$gitProducts = $wmiProductObject | where {$_.Name -and $_.Name.Contains("Node")}
$gitProducts = Get-ItemProperty HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\* | where {$_.DisplayName -and $_.DisplayName.Contains("Git")}


$installGit = $true
try {
    $localGitVersion = $gitProducts.DisplayVersion
    if($localGitVersion -and $localGitVersion.Contains($gitVersion)){
        $installGit = $false
        Write-Host "Latest version is already installed: git - $gitVersion" -ForegroundColor Green
    }
}catch{
    $installGit=$true
    Write-Host "Local instance of git not found"
}


#Install parameters (components) located at: github.com/git-for-windows/build-extra/blob/main/installer/install.iss#L105
# https://silentinstallhq.com/git-silent-install-how-to-guide/
if(!$gitProducts -or $installGit){
    Write-Host "Installing Git..."
    $installationFilePath = $installationPathRoot+'git.exe'
    $webClient.DownloadFile($gitDownloadLink, $installationFilePath)
    Start-Process -Wait $installationFilePath -ArgumentList @('/VERYSILENT', '/COMPONENTS="icons,ext\reg\shellhere,assoc,assoc_sh"')
}
