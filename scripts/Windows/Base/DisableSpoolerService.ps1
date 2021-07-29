$ErrorActionPreference = "Stop"
$VerbosePreference="Continue"

#Disable spooler service for CVE-2021-34527
Set-Service -name spooler -startupType disabled

Write-Host "Spooler service has been disabled." -ForegroundColor Green