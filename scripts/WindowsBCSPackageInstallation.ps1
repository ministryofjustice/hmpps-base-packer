$ErrorActionPreference = "Stop"
$VerbosePreference="Continue"
Add-Type -AssemblyName System.IO.Compression.FileSystem
echo "s3://$env:ARTIFACT_BUCKET/mis/Data Services Related/win32_11gR2_client.zip"
# Get our oracle packages from s3
aws s3 cp "s3://$env:ARTIFACT_BUCKET/mis/Data Services Related/win32_11gR2_client.zip" c:\temp\win32_11gR2_client.zip
aws s3 cp "s3://$env:ARTIFACT_BUCKET/mis/Data Services Related/win64_11gR2_client.zip" c:\temp\win64_11gR2_client.zip

[System.IO.Compression.ZipFile]::ExtractToDirectory("c:\\temp\\win32_11gR2_client.zip", "C:\\temp")
[System.IO.Compression.ZipFile]::ExtractToDirectory("c:\\temp\\win64_11gR2_client.zip", "C:\\temp")


