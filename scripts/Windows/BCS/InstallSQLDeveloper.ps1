$ErrorActionPreference = "Stop"
$VerbosePreference="Continue"
Add-Type -AssemblyName System.IO.Compression.FileSystem

aws s3 cp "s3://$env:ARTIFACT_BUCKET/mis/oracle-sqldeveloper.zip" C:\temp\sqldeveloper.zip

# extract to D: unless it doesn't exist
$ExtractDrive = "D"

If (!(Test-Path D:))
{
    $ExtractDrive = "C"
}

[System.IO.Compression.ZipFile]::ExtractToDirectory("C:\\temp\\sqldeveloper.zip", "${ExtractDrive}:\\")

[System.Environment]::SetEnvironmentVariable("Path", $env:Path + ";${ExtractDrive}:\sqldeveloper", [EnvironmentVariableTarget]::Machine)

[System.Environment]::GetEnvironmentVariable("Path", [EnvironmentVariableTarget]::Machine)