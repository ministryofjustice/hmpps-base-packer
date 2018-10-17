$ErrorActionPreference = "Stop"
$VerbosePreference="Continue"

# Update the admin user
$jenkinsCreds = New-Credential -UserName Jenkins -Password "$env:JENKINS_PASSWORD"
Install-User -Credential $jenkinsCreds
