$ErrorActionPreference = "Stop"
$VerbosePreference="Continue"
Add-Type -AssemblyName System.IO.Compression.FileSystem

# Get our oracle packages from s3
aws s3 cp "s3://$env:ARTIFACT_BUCKET/mis/Data Services Related/OpenSSH-Win64.zip" c:\temp\OpenSSH-Win64.zip

#Ensure our folder is created with the correct permissions
$openssh_install_path = "C:\Program Files\OpenSSH"
Install-Directory -Path $openssh_install_path

#Unpack our installer
[System.IO.Compression.ZipFile]::ExtractToDirectory("c:\\temp\\OpenSSH-Win64.zip", $openssh_install_path)

#Install sshd
powershell.exe -ExecutionPolicy Bypass -File "$openssh_install_path\install-sshd.ps1"

#Add firewall rule
New-NetFirewallRule -Name sshd -DisplayName 'OpenSSH Server (sshd)' -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 22

#Add openssh to path
[System.Environment]::SetEnvironmentVariable("Path", $env:Path + ";$openssh_install_path", [EnvironmentVariableTarget]::Machine)

#Set default shell
New-ItemProperty -Path "HKLM:\SOFTWARE\OpenSSH" -Name DefaultShell -Value "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" -PropertyType String -Force
New-ItemProperty -Path "HKLM:\SOFTWARE\OpenSSH" -Name DefaultShellCommandOption -Value "/c" -PropertyType String -Force

net start sshd
Set-Service sshd -StartupType Automatic
