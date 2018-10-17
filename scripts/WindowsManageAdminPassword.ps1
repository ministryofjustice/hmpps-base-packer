$ErrorActionPreference = "Stop"
$VerbosePreference="Continue"

gci env:* | sort-object name

# Update the admin user
$adminCreds = New-Credential -UserName Administrator -Password "$env:ADMIN_PASSWORD"
Install-User -Credential $adminCreds
