
$ErrorActionPreference = "Stop"
$VerbosePreference="Continue"

Set-ExecutionPolicy Bypass

if( false -eq Test-Path -Path "C:\setup") {
    New-Item -Path "c:\" -Name "temp" -ItemType "directory"
}

#----------------------------------------------------------------------
# Download Karma Binaries from S3 Bucket 
#----------------------------------------------------------------------
# tf-eu-west-2-hmpps-eng-dev-artefacts-cporacle-s3bucket in eng-dev
$KarmaFileName = "karma-v1.0.226.666.zip"

Write-Output "Copying Karma Zip file from s3://$env:ARTIFACT_BUCKET/$KarmaFileName"
aws s3 cp "s3://$env:ARTIFACT_BUCKET/$KarmaFileName" c:\setup\$KarmaFileName

Write-Output "Extracting Karma Zip to c:\inetpub\cporacle"
Add-Type -AssemblyName System.IO.Compression.FileSystem
[System.IO.Compression.ZipFile]::ExtractToDirectory("c:\\setup\\$KarmaFileName", "C:\\inetpub\\cporacle")

Write-Output "Removing Default Web Site"
Remove-IISSite -Name "Default Web Site"

Write-Output "Creating CPOracle Web Application"


Start-IISCommitDelay

$TestSite = New-IISSite -Name CPOracle 
                        -BindingInformation "*:80:" 
                        -PhysicalPath "$env:systemdrive\inetpub\cporacle" 
                        -Passthru

$TestSite.Applications["/"].ApplicationPoolName = "TestSiteAppPool"

Stop-IISCommitDelay

Get-IISSite "CPOracle"