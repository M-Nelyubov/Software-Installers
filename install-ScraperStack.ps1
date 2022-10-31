<#
 .SYNOPSIS
     Automatically installs the latest version of git for windows, GitHub Desktop, node.js, and notepad++
 .OUTPUTS
     Confirmation of the latest installed version numbers will be printed
 
 .DESCRIPTION
 
     Version:         0.5
     Author:          mnelyubo@buffalo.edu
     Date Created:    2021/07/01
     Last Modified:   2022/10/21
 
     This script does the following tasks:
         Install Git for Windows
         Install GitHub Desktop
         Install Node.js
         Install Notepad++
     
     Requirements:
         Internet connection
         Administrative execution
 
     Patch Notes:
         0.1:    Added Notepad++
         0.2:    Added header to file
         0.3:    Switched Git for Windows silent install argument from '/SILENT' to '/VERYSILENT'
         0.3.1:  Added links for Git for Desktop installation references
         0.4:    Added dependency stack for the PowerShell GraphViz library
         0.4.1:  Set powershell environment variables to reset after all installs
         0.5:    Reworked to run off of individual program modules.  Use those individual scripts to install just a single app
 
 .EXAMPLE
     PS> .\install-DevStack.ps1
     Checking already installed programs...
     Latest version is already installed: git - 2.35.1
     Latest version is already installed: git desktop - 2.9.11 
     Latest version is already installed: node.js -16.14.0
     Latest version is already installed: NPP - 8.3.2
#>

#allow parameters to specify installing only a specific software from the set
param([string]$installationPathRoot = "C:\temp\")

if(-not (Test-Path -Path $installationPathRoot -PathType Container)){
    Write-Host "Creating $installationPathRoot"
    mkdir $installationPathRoot | Out-Null
}

# The list of applications to install
$targetApps = @(
    "Git"
    "GitHubDesktop"
    "nodeJs"
    "npp"
)

$targetApps | foreach {"$PSScriptRoot\applications\install-$_.ps1"} | where {Test-Path $_} | foreach {
    Start-Process powershell.exe -ArgumentList @($_) -Wait -NoNewWindow
}

# Reload ENV Path after installing apps
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User") 

