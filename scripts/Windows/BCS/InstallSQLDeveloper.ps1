$ErrorActionPreference = "Stop"
$VerbosePreference="Continue"
Add-Type -AssemblyName System.IO.Compression.FileSystem

aws s3 cp "s3://$env:ARTIFACT_BUCKET/mis/oracle-sqldeveloper.zip" C:\temp\sqldeveloper.zip
[System.IO.Compression.ZipFile]::ExtractToDirectory("C:\\temp\\sqldeveloper.zip", "D:\\")

[System.Environment]::SetEnvironmentVariable("Path", $env:Path + ";D:\sqldeveloper", [EnvironmentVariableTarget]::Machine)
