$VerbosePreference="Continue"
Set-ExecutionPolicy Bypass -Force

Write-Output('Start of SetRDSEndpointRegistryKeys.ps1 ---->')

# Currently AWS CLI is needed to get the rds endpoint

### INSTALL AWS CLI ###
Write-Output('Installing AWS CLI')
Invoke-WebRequest -Uri https://awscli.amazonaws.com/AWSCLIV2.msi -Outfile "C:\aws.msi"
Start-Process -Wait -FilePath msiexec -ArgumentList /i, "c:\aws.msi", /qn
Remove-Item "c:\aws.msi"
Write-Output('Finished installing AWS CLI')
### FINISH INSTALLING AWS CLI ###

Write-Output('Fetching CPOracle Configuration from SSM Parameter Store and existing RDS endpoint')

Write-Output('Get the RDS Endpoint for the CPOracle Database')
$RDSEndpoint=(aws rds describe-db-instances --db-instance-identifier 'cp-oracle-native-backup-restore' --query 'DBInstances[].Endpoint.Address' --output text)
Write-Output("Using RDS Endpoint '" + $RDSEndpoint + "'")

$cporacle_app_username_SSMPath = "/" + $environmentName.Value + "/cr/cporacle/rds/cporacle_app_username"
Write-Output("get ssm param $cporacle_app_username_SSMPath")
$cporacle_app_username = Get-SSMParameter -Name $cporacle_app_username_SSMPath -WithDecryption $true
Write-Output("cporacle_app_username: " + $cporacle_app_username.Value)

$cporacle_app_password_SSMPath = "/" + $environmentName.Value + "/cr/cporacle/rds/cporacle_app_password"
Write-Output("get ssm param $cporacle_app_password_SSMPath")
$cporacle_app_password = Get-SSMParameter -Name $cporacle_app_password_SSMPath -WithDecryption $true
Write-Output("cporacle_app_password: " + $cporacle_app_password.Value)

New-Item -Path HKLM:\Software\HMMPS -Name rdsendpoint -Force -Value “$RDSEndpoint”
New-Item -Path HKLM:\Software\HMMPS -Name cporacleappuser -Force -Value “$cporacle_app_username.Value”
New-Item -Path HKLM:\Software\HMMPS -Name cporacleapppw -Force -Value “$cporacle_app_password.Value”

### REMOVE AWS CLI ###
Write-Output('Removing AWS CLI')
$MyApp = Get-WmiObject -Class Win32_Product | Where-Object{$_.Name -eq "AWS Command Line Interface v2"}
$MyApp.Uninstall()
Write-Output('Finished removing AWS CLI')
### FINISH REMOVING AWS CLI ###

Write-Output('<---- End of of SetRDSEndpointRegistryKeys.ps1')

