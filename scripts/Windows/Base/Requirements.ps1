[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12


$ChocoInstallPath = "$env:SystemDrive\ProgramData\Chocolatey\bin"
$ErrorActionPreference = "Stop"
$VerbosePreference="Continue"

if (!(Test-Path $ChocoInstallPath)) {
    iex ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1'))
}

# Install awscli, jq and python2
choco install miniconda3 -params="/InstallationType=AllUsers /AddToPath=1" -y --version 4.5.12

#Awscli
choco install -y awscli --version 2.0.10

#JQ
choco install jq -y --version 1.6

#Carbon
choco install carbon -y --version 2.9.2
