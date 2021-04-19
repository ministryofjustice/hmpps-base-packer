$ErrorActionPreference = "Stop"
$VerbosePreference="Continue"

Import-Module 'Carbon'

# Update the admin user
$adminCreds = New-Credential -UserName Administrator -Password "$env:WIN_ADMIN_PASS"
Install-User -Credential $adminCreds
