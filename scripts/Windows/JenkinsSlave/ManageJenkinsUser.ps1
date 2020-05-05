$ErrorActionPreference = "Stop"
$VerbosePreference="Continue"

Import-Module 'Carbon'

# Create jenkins user
# Get our our password details from ssm
#$keyname = "/$env:TARGET_ENV/jenkins/windows/slave/jenkins/password"
#$jenkins_password = (aws --region eu-west-2 ssm get-parameters --with-decryption --names ${keyname} --query Parameters[0].Value)
$jenkinsCreds = New-Credential -UserName Jenkins -Password "$env:JENKINS_PASS"
Install-User -Credential $jenkinsCreds
Add-GroupMember -Name Administrators -Member Jenkins

#Create JenkinsHome directory on root
Install-Directory -Path "c:\JenkinsHome"
[System.Environment]::SetEnvironmentVariable('JENKINS_HOME', 'C:\JenkinsHome', [System.EnvironmentVariableTarget]::Machine)

#As it says on the tin
Disable-IEEnhancedSecurityConfiguration
