$ChocoInstallPath = "$env:SystemDrive\ProgramData\Chocolatey\bin"
$ErrorActionPreference = "Stop"
$VerbosePreference="Continue"

if (!(Test-Path $ChocoInstallPath)) {
    iex ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1'))
}

#--- Python ---
choco install python2 -y
#--- JDK 8 ---
choco install jdk8 make -y
#--- Maven and gradle
choco install maven gradle -y

#--- Download firefox
$url = "https://ftp.mozilla.org/pub/firefox/releases/52.9.0esr/win64/en-US/Firefox%20Setup%2052.9.0esr.exe"
$output = "$env:temp\setup.exe"

$wc = New-Object System.Net.WebClient
$wc.DownloadFile($url, $output)

gdr -PSProvider 'FileSystem'

& "$env:temp\setup.exe" -ms /INI=c:\temp\firefox.ini

$Path = "C:\"

Tree $Path | Select-String("firefox")

#java -jar agent.jar -jnlpUrl http://jenkins.engineering-dev.probation.hmpps.dsd.io:8080/computer/windows_slave/slave-agent.jnlp -secret 82c3364892fc7d5c695de30faa0a1792d0795f7e349c18107de0d030cc94fc42 -workDir "c:/jenkins"