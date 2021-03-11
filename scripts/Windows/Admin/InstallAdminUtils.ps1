$ErrorActionPreference = "Stop"
$VerbosePreference="Continue"

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$ChocoInstallPath = "$env:SystemDrive\ProgramData\Chocolatey\bin"
$ErrorActionPreference = "Stop"
$VerbosePreference="Continue"

if (!(Test-Path $ChocoInstallPath)) {
    Invoke-Expression ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1'))
}

# Install notepad++
choco install notepadplusplus -y

# AdExplorer - https://docs.microsoft.com/en-us/sysinternals/downloads/adexplorer
Add-Type -AssemblyName System.IO.Compression.FileSystem
aws s3 cp "s3://$env:ARTIFACT_BUCKET/mis/AdExplorer.zip" c:\temp\AdExplorer.zip
[System.IO.Compression.ZipFile]::ExtractToDirectory("c:\\temp\\AdExplorer.zip", "C:\\temp\\AdExplorer")
