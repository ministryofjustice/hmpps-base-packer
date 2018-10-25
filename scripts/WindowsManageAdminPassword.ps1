$ErrorActionPreference = "Stop"
$VerbosePreference="Continue"

# Get our our password details from ssm
$keyname = "/$env:TARGET_ENV/jenkins/windows/slave/admin/password"
echo $keyname
$admin_password = (aws --region eu-west-2 ssm get-parameters --with-decryption --names ${keyname} --query Parameter.Value)
echo $admin_password.length
# Update the admin user
$adminCreds = New-Credential -UserName Administrator -Password "$admin_password"
Install-User -Credential $adminCreds
