$ErrorActionPreference = "Stop"
$VerbosePreference="Continue"
Add-Type -AssemblyName System.IO.Compression.FileSystem

# Get our oracle packages from s3
aws s3 cp "s3://$env:ARTIFACT_BUCKET/mis/oracle_11204_win64_client.zip" c:\temp\win64_11gR2_client.zip

#Unpack our installer
[System.IO.Compression.ZipFile]::ExtractToDirectory("c:\\temp\\win64_11gR2_client.zip", "C:\\temp")
Rename-Item -Path C:\temp\client -NewName c:\temp\ora64_installer

$command = "c:\temp\ora64_installer\setup.exe"
$arguments = "-silent -nowelcome -nowait -noconfig  -responseFile c:\temp\ora64_client.rsp -showProgress"

#Run our process in the foreground, wait till spawned window terminates
Start-Process $cmd "$arguments" -NoNewWindow -Wait

$logFiles = Get-ChildItem "$env:SYSTEM_DRIVE\Program Files\Oracle\Inventory\logs\silent*.log"

foreach ($logFile in $logfiles.Name) {
    type "$env:SYSTEM_DRIVE\Program Files\Oracle\Inventory\logs\$logFile"
}