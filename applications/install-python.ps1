
$VersionSite     = "https://python.org/downloads"
$webPageFilePath = "C:\Users\$env:username\AppData\Local\Temp\python-site.html"


$webClient = (New-Object System.Net.WebClient)
$webClient.DownloadFile($VersionSite, $webPageFilePath)

$startText = '<span class="release-version">';


$fileData = @((Get-Content -Path $webPageFilePath) | Where-Object {$_.Contains($startText)} | Where-Object {-not ($_.Contains("Python version"))})[0]
$currentMajor = ([xml]$fileData).span."#text"

$fileData = @((Get-Content -Path $webPageFilePath))
$minorReleaseData = $fileData | where {$_.COntains($currentMajor)} | where {$_.COntains(".exe")} | foreach {([xml] $_).a}
$currentVersion = $minorReleaseData."#text".Split(" ")[-1]
$downloadUrl = $minorReleaseData.href

$currentlyInstalled = "HKLM:\SOFTWARE\Python\PythonCore\" | where {Test-Path $_} | foreach {ls $_} | foreach {$_.GetValue('Version')}
if($currentVersion -in $currentlyInstalled){
    Write-Host -ForegroundColor Green "Latest version is already installed: Python - $currentVersion"
    exit
}

Write-Host "Installing Python $currentVersion"

# Download the .exe for the latest version of Python
$downloadUrl = "https://www.python.org/ftp/python/$currentVersion/python-$currentVersion-amd64.exe"
$installerPath = "C:\Users\$env:username\AppData\Local\Temp\python-$currentVersion.exe"
Write-Host ($downloadUrl, $installerPath)
$webClient.DownloadFile($downloadUrl, $installerPath)

# Silently install the downloaded Python exe
# Arguments from: https://silentinstallhq.com/python-3-10-silent-install-how-to-guide/
Start-Process -FilePath $installerPath -ArgumentList "/quiet InstallAllUsers=1 PrependPath=1" -Wait
