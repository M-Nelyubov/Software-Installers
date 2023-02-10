# Software-Installers
A collection of PowerShell scripts for automatically installing the latest versions of some software
 
## How to run
### Option 1: Manual Install
1. Download the repository locally. Examples:
    - Use an existing installation of Git to clone the repository `git clone https://github.com/MSNelyubov/Software-Installers.git`
    - Download and extract the repository as a [zip file here](https://github.com/MSNelyubov/Software-Installers/archive/refs/heads/main.zip).
2. Open an administrative PowerShell session with the shortcut (Win + X) -> A
3. Change the directory in the PowerShell terminal to where you downloaded the repository
    - e.g. `cd ~\Documents\GitHub\Software-Installers`
    - e.g. `cd ~\Downloads\Software-Installers-main\Software-Installers-main`
4. Run the PowerShell scripts for the software you want to install
    - e.g. `.\applications\install-nodeJs.ps1`
5. Wait for the installation to complete
6. You're done! Run the installed software to make sure everything is working as desired.

### Option 2: Automated Install
1. Open PowerShell as an Administrator
2. Run the following command:
```ps1
$dp="~/AppData/Local/Temp/install-Git.ps1"; Invoke-WebRequest -Uri "https://raw.githubusercontent.com/M-Nelyubov/Software-Installers/main/applications/install-Git.ps1" -UseBasicParsing | foreach {$_.Content} | Set-Content -Path $dp; Unblock-File $dp; Set-ExecutionPolicy Unrestricted -Scope Process -Force; Start-Process -Wait powershell.exe -ArgumentList $dp -NoNewWindow; $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User"); mkdir ~\Documents\GitHub\ -ErrorAction SilentlyContinue; cd "~\Documents\GitHub\"; git clone https://github.com/M-Nelyubov/Software-Installers.git
```
3. Run the PowerShell scripts for the software you want to install
    - e.g. `.\applications\install-nodeJs.ps1`
4. Wait for the installation to complete
5. You're done! Run the installed software to make sure everything is working as desired.

## Error Handling

### Running scripts is disabled

If this is your first time running a PowerShell script, you may see an error like this:

```
 .\install-GitHubDesktop : File ....\Software-Installers-main\applications\install-GitHubDesktop.ps1
cannot be loaded because running scripts is disabled on this system. For more information, see about_Execution_Policies at
https:/go.microsoft.com/fwlink/?LinkID=135170.
At line:1 char:1
+ .\install-GitHubDesktop
+ ~~~~~~~
    + CategoryInfo          : SecurityError: (:) [], PSSecurityException
    + FullyQualifiedErrorId : UnauthorizedAccess
```

In order to proceed past this error, run the following command: `Set-ExecutionPolicy RemoteSigned` and then retry running the script that you attempted to run before.

