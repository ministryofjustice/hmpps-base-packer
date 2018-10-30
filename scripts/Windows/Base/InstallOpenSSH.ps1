$ErrorActionPreference = "Stop"
$VerbosePreference="Continue"
Add-Type -AssemblyName System.IO.Compression.FileSystem

# Get our oracle packages from s3
aws s3 cp "s3://$env:ARTIFACT_BUCKET/mis/Data Services Related/OpenSSH-Win64.zip" c:\temp\OpenSSH-Win64.zip

#Ensure our folder is created with the correct permissions
$openssh_install_path = "C:\\Program Files\\OpenSSH"
New-Item -Path $openssh_install_path -Type Directory

Revoke-Permission -Identity
Carbon_Permission GrantPermission
{
    Path = $openssh_install_path;
    Identity = 'CarbonServiceUser';
    Permission = 'ReadAndExecute';
}

#Unpack our installer
[System.IO.Compression.ZipFile]::ExtractToDirectory("c:\\temp\\OpenSSH-Win64.zip", "$openssh_install_path")
