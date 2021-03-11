$ErrorActionPreference = "Stop"
$VerbosePreference="Continue"
Add-Type -AssemblyName System.IO.Compression.FileSystem

# Get our oracle packages from s3
aws s3 cp "s3://$env:ARTIFACT_BUCKET/mis/oracle_11204_win64_client.zip" c:\temp\win64_11gR2_client.zip

#Unpack our installer
[System.IO.Compression.ZipFile]::ExtractToDirectory("c:\\temp\\win64_11gR2_client.zip", "C:\\temp")
Rename-Item -Path C:\temp\client -NewName c:\temp\ora64_installer

#Get our current IP address
$my_ip = curl  http://169.254.169.254/latest/meta-data/local-ipv4
$my_ip = $my_ip.Content

#Run our installer
$command = "c:\temp\ora64_installer\setup.exe"
$arguments = "-silent -nowelcome -nowait -noconfig -responseFile c:\temp\ora64_client.rsp -showProgress oracle.install.client.schedulerAgentHostName=$my_ip"

#Run our process in the foreground, wait till spawned window terminates
Start-Process -FilePath $command -ArgumentList $arguments -NoNewWindow -Wait

#Windows is as windows does
Start-Sleep -Seconds 30

$logFiles = Get-ChildItem "$env:SYSTEM_DRIVE\Program Files\Oracle\Inventory\logs\silent*.log" -ErrorAction Ignore

foreach ($logFile in $logfiles.Name) {
    Get-Content "$env:SYSTEM_DRIVE\Program Files\Oracle\Inventory\logs\$logFile"
}
