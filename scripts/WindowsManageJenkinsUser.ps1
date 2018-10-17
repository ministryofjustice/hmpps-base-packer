$ErrorActionPreference = "Stop"
$VerbosePreference="Continue"

$jenkinsCreds = New-Credential -UserName Jenkins -Password "$env:JENKINS_PASSWORD"
Install-User -Credential $jenkinsCreds

Add-GroupMember -Name Administrators -Member Jenkins

Install-Directory -Path "c:\JenkinsHome"
