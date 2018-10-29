$ErrorActionPreference = "Stop"
$VerbosePreference="Continue"
Add-Type -AssemblyName System.IO.Compression.FileSystem

aws s3 cp "s3://$env:ARTIFACT_BUCKET/mis/sqldeveloper-18.3.0.277.2354-no-jre.zip" d:\sqldeveloper.zip
[System.IO.Compression.ZipFile]::ExtractToDirectory("D:\\sqldeveloper.zip", "D:\\")
Remove-Item –path D:\sqldeveloper.zip –recurse
[System.Environment]::SetEnvironmentVariable("Path", $env:Path + ";D:\sqldeveloper", [EnvironmentVariableTarget]::Machine)
