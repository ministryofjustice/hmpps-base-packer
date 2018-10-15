$ChocoInstallPath = "$env:SystemDrive\ProgramData\Chocolatey\bin"

if (!(Test-Path $ChocoInstallPath)) {
    iex ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1'))
}

#--- Python ---
choco install python2 -y
#--- JDK 8 ---
choco install jdk8 -y
#--- Maven and gradle
choco install maven gradle -y

# Get firefox esr
$url = "https://ftp.mozilla.org/pub/firefox/releases/52.9.0esr/win64/en-US/Firefox%20Setup%2052.9.0esr.exe"
$output = "$env:temp\install-firefox.exe"

$wc = New-Object System.Net.WebClient
(New-Object System.Net.WebClient).DownloadFile($url, $output)

#--- install firefox
$pathvargs = {$output /S /INI=$env:temp\firefox.ini }
Invoke-Command -ScriptBlock $pathvargs
