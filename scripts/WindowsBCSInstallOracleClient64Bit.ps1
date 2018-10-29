$ErrorActionPreference = "Stop"
$VerbosePreference="Continue"
Add-Type -AssemblyName System.IO.Compression.FileSystem

# Get our oracle packages from s3
aws s3 cp "s3://$env:ARTIFACT_BUCKET/mis/Data Services Related/win64_11gR2_client.zip" c:\temp\win64_11gR2_client.zip

#Unpack our installer
[System.IO.Compression.ZipFile]::ExtractToDirectory("c:\\temp\\win64_11gR2_client.zip", "C:\\temp")
Rename-Item -Path C:\temp\client -NewName c:\temp\ora64_installer
#Remove-Item –path C:\temp\win64_11gR2_client.zip –recurse
