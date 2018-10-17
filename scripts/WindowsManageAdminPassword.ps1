$ErrorActionPreference = "Stop"
$VerbosePreference="Continue"

# Get our admin password
$adminPass = aws ssm get-parameters --names /dev/jenkins/windows/slave/admin/password --region eu-west-2 --with-decrypt | jq -r '.Parameters[0].Value'
# Update the admin user
Install-User -UserName Administrator -Password "$adminPass"