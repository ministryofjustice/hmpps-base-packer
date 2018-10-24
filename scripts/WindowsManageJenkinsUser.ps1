$ErrorActionPreference = "Stop"
$VerbosePreference="Continue"

# Create jenkins user
$jenkinsCreds = New-Credential -UserName Jenkins -Password "$env:JENKINS_PASSWORD"
Install-User -Credential $jenkinsCreds
Add-GroupMember -Name Administrators -Member Jenkins

#Create JenkinsHome directory on root
Install-Directory -Path "c:\JenkinsHome"
[System.Environment]::SetEnvironmentVariable('JENKINS_HOME', 'C:\JenkinsHome', [System.EnvironmentVariableTarget]::Machine)

#As it says on the tin
Disable-IEEnhancedSecurityConfiguration
