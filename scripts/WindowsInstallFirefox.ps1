$ErrorActionPreference = "Stop"
$VerbosePreference="Continue"

#--- Download firefox
$url = "https://ftp.mozilla.org/pub/firefox/releases/52.9.0esr/win64/en-US/Firefox%20Setup%2052.9.0esr.exe"
$output = "$env:temp\setup.exe"
$wc = New-Object System.Net.WebClient
$wc.DownloadFile($url, $output)
& "$env:temp\setup.exe" -ms /INI=c:\temp\firefox.ini