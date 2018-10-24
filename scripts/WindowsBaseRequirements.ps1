
$ChocoInstallPath = "$env:SystemDrive\ProgramData\Chocolatey\bin"
$ErrorActionPreference = "Stop"
$VerbosePreference="Continue"

if (!(Test-Path $ChocoInstallPath)) {
    iex ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1'))
}

# Install awscli, jq and python2
choco install python2 miniconda -params="/InstallationType=AllUsers /AddToPath=1" -y
choco install -y awscli jq carbon
