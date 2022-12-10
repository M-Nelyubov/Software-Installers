# Software-Installers
A collection of PowerShell scripts for automatically installing the latest versions of some software
 
## How to run
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
6. Test the installation to make sure it worked
    - e.g. `node --version` will return the latest version of node.js if it was successfully installed

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

