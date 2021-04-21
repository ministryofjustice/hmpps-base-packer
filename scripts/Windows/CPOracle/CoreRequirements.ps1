Write-Output "------------------------------------"
Write-Output "Install latest SSM Agent"
Write-Output "------------------------------------"
Invoke-WebRequest https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/windows_amd64/AmazonSSMAgentSetup.exe -OutFile $env:USERPROFILE\Desktop\SSMAgent_latest.exe
Start-Process -FilePath $env:USERPROFILE\Desktop\SSMAgent_latest.exe -ArgumentList "/S"

Write-Output "----------------------------------------------"
Write-Output "Install IIS Webserver, .NET Framework 4.5"
Write-Output "----------------------------------------------"
Install-WindowsFeature -name Web-Server -IncludeManagementTools
Install-WindowsFeature Net-Framework-45-Features
Get-WindowsFeature | where { $_.InstallState -eq "Installed" } | Format-Table 



