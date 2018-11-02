$ErrorActionPreference = "Stop"
$VerbosePreference="Continue"

Set-ExecutionPolicy Bypass

$ErrorActionPreference = "silentlycontinue"
#We have a failing KB at present, so lets skip the error
#--- Visual C++ ----
choco install vcredist2012 vcredist2015 vcredist-all -y --force
$ErrorActionPreference = "Stop"

#--- DotNet 4.5 ---
choco install dotnet4.5 dotnet4.5.2 -y

#Get .net3.5
aws s3 cp "s3://$env:ARTIFACT_BUCKET/mis/dotNetFx35setup.exe" c:\temp\dotNetFx35setup.exe
#Install .net3.5
Install-WindowsFeature Net-Framework-Core -source C:\temp
