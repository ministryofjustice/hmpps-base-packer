
$ChocoInstallPath = "$env:SystemDrive\ProgramData\Chocolatey\bin"
$ErrorActionPreference = "Stop"
$VerbosePreference="Continue"

if (!(Test-Path $ChocoInstallPath)) {
    iex ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1'))
}

# Install awscli, jq and python2
choco install miniconda3 -params="/InstallationType=AllUsers /AddToPath=1" -y

#Awscli
choco install -y awscli

#JQ
choco install jq -y

#Carbon
choco install carbon -y
