# Software-Installers
A collection of PowerShell scripts for automatically installing the latest versions of some software
 
## How to run
1. Download the repository locally. Examples:
    - Use an existing installation of Git to clone the repository `git clone https://github.com/MSNelyubov/Software-Installers.git`
    - Download and extract the repository as a [zip file here](https://github.com/MSNelyubov/Software-Installers/archive/refs/heads/main.zip).
2. Open an administrative PowerShell session with the shortcut (Win + X) -> A
3. Change the directory in the PowerShell terminal to where you downloaded the repository
    - e.g. `cd ~\Documents\GitHub\Software-Installers`
    - e.g. `cd ~\Downloads\Software-Installers`
4. Run the PowerShell scripts for the software you want to install
    - e.g. `.\applications\install-nodeJs.ps1`
5. Wait for the installation to complete
6. Test the installation to make sure it worked
    - e.g. `node --version` will return the latest version of node.js if it was successfully installed
