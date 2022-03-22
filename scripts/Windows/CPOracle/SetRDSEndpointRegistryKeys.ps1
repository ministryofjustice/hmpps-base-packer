$VerbosePreference="Continue"
Set-ExecutionPolicy Bypass -Force
$key = "HKLM:\Software\HMPPS"
$environmentName = (Get-ItemProperty -Path $key -Name "cporacleenvironmentname").cporacleenvironmentname

Write-Output('Start of SetRDSEndpointRegistryKeys.ps1 ---->')

Write-Output('Fetching CPOracle Configuration from SSM Parameter Store and existing RDS endpoint')
Write-Output('Get the RDS Endpoint for the CPOracle Database')
$RDSEndpoint=(aws rds describe-db-instances --db-instance-identifier 'cp-oracle-native-backup-restore' --query 'DBInstances[].Endpoint.Address' --output text)
Write-Output("Using RDS Endpoint '" + $RDSEndpoint + "'")

$cporacle_app_username_SSMPath = "/" + $environmentName + "/cr/cporacle/rds/cporacle_app_username"
Write-Output("get ssm param $cporacle_app_username_SSMPath")
$cporacle_app_username = Get-SSMParameter -Name $cporacle_app_username_SSMPath -WithDecryption $true
Write-Output("cporacle_app_username: " + $cporacle_app_username.Value)

$cporacle_app_password_SSMPath = "/" + $environmentName + "/cr/cporacle/rds/cporacle_app_password"
Write-Output("get ssm param $cporacle_app_password_SSMPath")
$cporacle_app_password = Get-SSMParameter -Name $cporacle_app_password_SSMPath -WithDecryption $true
Write-Output("cporacle_app_password: " + $cporacle_app_password.Value)

$cporacle_encryp_key_SSMPath = "/" + $environmentName + "/cr-unpaid-work-dev/cr/cporacle/application/encryption_key"
Write-Output("cporacle_key_path: " + $cporacle_encryp_key_SSMPath)

Set-ItemProperty -Path $Key -Name rdsendpoint -Force -Value $RDSEndpoint
Set-ItemProperty -Path $Key -Name cporacleappuser -Force -Value $cporacle_app_username.Value
Set-ItemProperty -Path $Key -Name cporacleapppw -Force -Value $cporacle_app_password.Value
Set-ItemProperty -Path $Key -Name cporaclekeypath -Force -Value $cporacle_encryp_key_SSMPath

Write-Output('<---- End of of SetRDSEndpointRegistryKeys.ps1')

