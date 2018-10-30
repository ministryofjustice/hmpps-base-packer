$ErrorActionPreference = "Stop"
$VerbosePreference="Continue"
Add-Type -AssemblyName System.IO.Compression.FileSystem

# Get our oracle packages from s3
aws s3 cp "s3://$env:ARTIFACT_BUCKET/mis/PSYaml-master.zip" C:\temp\PSYaml-master.zip
[System.IO.Compression.ZipFile]::ExtractToDirectory("C:\\temp\\PSYaml-master.zip", "C:\\temp")
mv C:\temp\PSYaml-master $env:USERPROFILE\Documents\WindowsPowerShell\Modules\
