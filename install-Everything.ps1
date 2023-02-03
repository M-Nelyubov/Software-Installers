<#
 .SYNOPSIS
     Automatically installs the latest version of everything in the applications directory

 .OUTPUTS
     Confirmation of the latest installed version numbers will be printed
 
 .DESCRIPTION
 
     Version:         0.1.0
     Author:          mnelyubo@buffalo.edu
     Date Created:    2023-02-02
     Last Modified:   2023-02-02
 
     This script does the following tasks:
	 Install GitHub CLI
         Install Git for Windows
         Install GitHub Desktop
         Install Node.js
         Install Notepad++
	 Install GraphViz

     
     Requirements:
         Internet connection
         Administrative execution
 
     Patch Notes:
         0.1.0:  Created
 
 .EXAMPLE
     PS> .\install-Everything.ps1
     Checking already installed programs...
     Latest version is already installed: git - 2.35.1
     Latest version is already installed: git desktop - 2.9.11 
     Latest version is already installed: node.js -16.14.0
     Latest version is already installed: NPP - 8.3.2
     Latest version is already installed: Chocolatey - 0.12.1
     Already installed: Graphviz
     Already installed: PSGraph 
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
    "GH"
    "GitHubDesktop"
    "nodeJs"
    "npp"
    "GraphViz"
)

ls "$PSScriptRoot\applications\install-*.ps1" | foreach {
    Start-Process powershell.exe -ArgumentList @($_) -Wait -NoNewWindow
}

# Reload ENV Path after installing apps
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User") 

