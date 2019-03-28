$ChocoInstallPath = "$env:SystemDrive\ProgramData\Chocolatey\bin"
$ErrorActionPreference = "Stop"
$VerbosePreference="Continue"

if (!(Test-Path $ChocoInstallPath)) {
    iex ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1'))
}

# Install awscli, jq and python2
choco install miniconda3 -params="/InstallationType=AllUsers /AddToPath=1" -y --version 4.5.12

#Awscli
choco install -y awscli --version 1.16.133

#JQ
choco install jq -y --version 1.5

#Carbon
choco install carbon -y --version 2.5.0
