<#
.SYNOPSIS
    Installs Git for Windows

.LINK
https://nodejs.org/en/
#>
param([string]$installationPathRoot = "C:\temp\")
$webClient = (New-Object System.Net.WebClient)
$webPageFilePath = $installationPathRoot +"site.html"

#Fetch latest version of nodejs
$VersionSite = "https://nodejs.org/en/"
$webClient.DownloadFile($VersionSite, $webPageFilePath)

$fileData = (Get-Content -Path $webPageFilePath) | where {$_.Contains("nodejs.org/dist/v")}
if($fileData.GetType().BaseType.Name -eq "Array"){
    $fileData = $fileData[0]
}


$fileData = $fileData.Substring($fileData.IndexOf("dist/v")+"dist/v".Length)
$fileData = $fileData.Substring(0,$fileData.IndexOf("/"))

$nodejsVersion = $fileData

#construct node download URLs
$nodejsDownloadBase = 'https://nodejs.org/dist/v'+$nodejsVersion+'/'
$nodejsFile = 'node-v'+$nodejsVersion+'-x64.msi'
$nodejsDownloadLink = $nodejsDownloadBase+$nodejsFile
$nodejsFileFull = "$installationPathRoot\$nodejsFile"

#check currently installed version in registry
$nodeProducts = Get-ItemProperty HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\* | where {$_.DisplayName -and $_.DisplayName.Contains("Node")}

# Install if not already at latest
if(!$nodeProducts -or ($nodeProducts.DisplayVersion -ne $nodejsVersion)){
    Write-Host "Installing node.js..."
    #SRC: https://gist.github.com/manuelbieh/4178908#file-win32-node-installer
    $webClient.DownloadFile($nodejsDownloadLink, $nodejsFileFull)
    msiexec /passive /log "$nodejsVersion.log" /package $nodejsFileFull
}else{
    Write-Host "Latest version is already installed: node.js - $nodejsVersion" -ForegroundColor Green
}
