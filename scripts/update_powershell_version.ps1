#$ErrorActionPreference = "Stop"
#$VerbosePreference="Continue"
#
##Upgrade powershell
#$url = "https://raw.githubusercontent.com/jborean93/ansible-windows/master/scripts/Upgrade-PowerShell.ps1"
#$file = "$env:temp\Upgrade-PowerShell.ps1"
#
#(New-Object -TypeName System.Net.WebClient).DownloadFile($url, $file)
#Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Force
#
## version can be 3.0, 4.0 or 5.1
#&$file -Version 5.1 -Username $username -Password $password -Verbose
#
## Memory hotfix
#$url = "https://raw.githubusercontent.com/jborean93/ansible-windows/master/scripts/Install-WMF3Hotfix.ps1"
#$file = "$env:temp\Install-WMF3Hotfix.ps1"
#
#(New-Object -TypeName System.Net.WebClient).DownloadFile($url, $file)
#powershell.exe -ExecutionPolicy ByPass -File $file -Verbose
