$ErrorActionPreference = "Stop"
$VerbosePreference="Continue"

Import-Module 'Carbon'


# Get our our password details from ssm
#$keyname = "/$env:TARGET_ENV/jenkins/windows/slave/admin/password"
#echo $env:TARGET_ENV
#$admin_password = (aws --region eu-west-2 ssm get-parameters --with-decryption --names ${keyname} --query Parameters[0].Value )
#echo ($admin_password -matches $env:WIN_ADMIN_PASS)
# Update the admin user
$adminCreds = New-Credential -UserName Administrator -Password "$env:WIN_ADMIN_PASS"
Install-User -Credential $adminCreds


