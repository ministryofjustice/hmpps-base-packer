# $ErrorActionPreference = "Stop"
$VerbosePreference="Continue"

Write-Output "------------------------------------"
Write-Output "Install latest SSM Agent"
Write-Output "------------------------------------"
Invoke-WebRequest https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/windows_amd64/AmazonSSMAgentSetup.exe -OutFile $env:USERPROFILE\Desktop\SSMAgent_latest.exe
Start-Process -FilePath $env:USERPROFILE\Desktop\SSMAgent_latest.exe -ArgumentList "/S"

Write-Output "----------------------------------------------"
Write-Output "Install IIS Webserver, .NET Framework 4.5"
Write-Output "----------------------------------------------"
Install-WindowsFeature -name Web-Server -IncludeManagementTools
Install-WindowsFeature -name Net-Framework-45-Features
Get-WindowsFeature | where { $_.InstallState -eq "Installed" } | Format-Table 

Write-Output "----------------------------------------------"
Write-Output "Install IIS Rewrite Module"
Write-Output "----------------------------------------------"

$Bucket        = "tf-eu-west-2-hmpps-eng-dev-artefacts-cporacle-s3bucket"
$region = "eu-west-2"
Copy-S3Object -BucketName $Bucket -Key "/website_dependencies/rewrite_amd64_en-US.msi" -LocalFile C:\Setup\rewrite_amd64_en-US.msi -Region $region

# Install the downloaded msi
Start-Process -FilePath C:\Setup\rewrite_amd64_en-US.msi -ArgumentList "/quiet"

Write-Output "----------------------------------------------"
Write-Output "Newtonsoft.Json.dll"
Write-Output "----------------------------------------------"
# download dll from S3
Copy-S3Object -BucketName $Bucket -Key "/website_dependencies/Newtonsoft.Json.dll" -LocalFile c:\setup\Newtonsoft.Json.dll -Region $region

Write-Output "Unblocking file c:\setup\Newtonsoft.Json.dll v"
Unblock-File -Path c:\setup\Newtonsoft.Json.dll

#  add dll to .NET GAC
#Note that you should be running PowerShell as an Administrator
[System.Reflection.Assembly]::Load("System.EnterpriseServices, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a")            
$publish = New-Object System.EnterpriseServices.Internal.Publish            
$publish.GacInstall("C:\Setup\Newtonsoft.Json.dll") 

# Create target location for website logs
New-Item -ItemType Directory -Path C:\CPOracle
New-Item -ItemType Directory -Path C:\CPOracle\logs

 
