$ErrorActionPreference = "Stop"
$VerbosePreference="Continue"
Add-Type -AssemblyName System.IO.Compression.FileSystem

aws s3 cp "s3://$env:ARTIFACT_BUCKET/mis/oracle-sqldeveloper.zip" D:\sqldeveloper.zip
[System.IO.Compression.ZipFile]::ExtractToDirectory("D:\\sqldeveloper.zip", "D:\\")

Get-PSDrive
Get-ChildItem -Path D:\

Remove-Item –path D:\sqldeveloper.zip –Recurse -ErrorAction Ignore
[System.Environment]::SetEnvironmentVariable("Path", $env:Path + ";D:\sqldeveloper", [EnvironmentVariableTarget]::Machine)
