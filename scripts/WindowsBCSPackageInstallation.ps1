$ErrorActionPreference = "Stop"
$VerbosePreference="Continue"
Add-Type -AssemblyName System.IO.Compression.FileSystem

# Get our oracle packages from s3
Read-S3Object -BucketName $env:ARTIFACT_BUCKET -Key mis/Data+Services+Related/win32_11gR2_client.zip -File c:\temp\win32_11gR2_client.zip
Read-S3Object -BucketName $env:ARTIFACT_BUCKET -Key mis/Data+Services+Related/win64_11gR2_client.zip -File c:\temp\win64_11gR2_client.zip

[System.IO.Compression.ZipFile]::ExtractToDirectory("c:\\temp\\win32_11gR2_client.zip", "C:\\temp")
[System.IO.Compression.ZipFile]::ExtractToDirectory("c:\\temp\\win64_11gR2_client.zip", "C:\\temp")


