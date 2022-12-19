<#
.SYNOPSIS
    Installs Git for Windows

.LINK
    https://cli.github.com/
#>

param([string]$installationPathRoot = "C:\temp\")
$webClient = (New-Object System.Net.WebClient)
$webPageFilePath = $installationPathRoot +"site.html"


if(-not (Test-Path -Path $installationPathRoot -PathType Container)){
    Write-Host "Creating $installationPathRoot"
    mkdir $installationPathRoot
}


#Fetch latest version of git 
$VersionSite = "https://cli.github.com/"

$webClient.DownloadFile($VersionSite, $webPageFilePath)

$startText = '//github.com/cli/cli/releases/download/v'
$endText   = '/'

$fileData = @((Get-Content -Path $webPageFilePath) | foreach {$_.Replace("'",'"')} | where {$_.Contains($startText)} | where {$_.Contains("windows")})[0]

$fileFromStartText = $fileData.Substring($fileData.IndexOf($startText) + $startText.Length)
$ghVersion = $fileFromStartText.Substring(0, $fileFromStartText.IndexOf($endText))

#Construct git download URL
$ghDownloadLink = ([xml]$fileData).a.href

#$wmiProductObject = Get-WmiObject Win32_Product
#$gitProducts = $wmiProductObject | where {$_.Name -and $_.Name.Contains("Node")}
$gitProducts = Get-ItemProperty HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\* | where {$_.DisplayName -like "GitHub CLI"}


$installGh = $true
try {
    $localGhVersion = $gitProducts.DisplayVersion
    if($localGhVersion -and $localGhVersion.Contains($ghVersion)){
        $installGh = $false
        Write-Host "Latest version is already installed: gh - $ghVersion" -ForegroundColor Green
    }
}catch{
    $installGh = $true
    Write-Host "Local instance of gh not found"
}


# https://silentinstallhq.com/git-silent-install-how-to-guide/
if(!$gitProducts -or $installGh){
    Write-Host "Installing GitHub CLI..."
    $installationFilePath = $installationPathRoot+'gh.msi'
    $webClient.DownloadFile($ghDownloadLink, $installationFilePath)
    msiexec /passive /log "$ghVersion.log" /package $installationFilePath
}

# Refresh Environment Variable
$env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")

# TODO: run `gh auth login`
