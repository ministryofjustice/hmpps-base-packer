$ErrorActionPreference = "Stop"
$VerbosePreference="Continue"

# Update the admin user
Install-Group Jenkins

$jenkinsCreds = New-Credential -UserName Jenkins -Password "$env:JENKINS_PASSWORD"
Install-User -Credential $jenkinsCreds

Add-GroupMember -Name Administrators -Member Jenkins
Add-GroupMember -Name Jenkins -Member Jenkins

Install-Directory -Path "c:\JenkinsHome"
