$ChocoInstallPath = "$env:SystemDrive\ProgramData\Chocolatey\bin"
$ErrorActionPreference = "Stop"
$VerbosePreference="Continue"

if (!(Test-Path $ChocoInstallPath)) {
    iex ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1'))
}

#--- Git ---
choco install git make -y
#--- JDK 8 ---
choco install jdk8 -y
#--- Maven and gradle
choco install maven gradle -y
#--- Install Non Sucking Service Manager
choco install nssm -y

#--- Download firefox
$url = "https://ftp.mozilla.org/pub/firefox/releases/52.9.0esr/win64/en-US/Firefox%20Setup%2052.9.0esr.exe"
$output = "$env:temp\setup.exe"

$wc = New-Object System.Net.WebClient
$wc.DownloadFile($url, $output)

& "$env:temp\setup.exe" -ms /INI=c:\temp\firefox.ini
# Set Java memory limits
[System.Environment]::SetEnvironmentVariable('JAVA_OPTS',  '-Xms4096m -Xmx8192m', [System.EnvironmentVariableTarget]::Machine)
[System.Environment]::SetEnvironmentVariable('_JAVA_OPTS',  '-Xms4096m -Xmx8192m', [System.EnvironmentVariableTarget]::Machine)
[System.Environment]::SetEnvironmentVariable('MAVEN_HOME',  'C:\ProgramData\chocolatey\lib\maven\apache-maven-3.5.4', [System.EnvironmentVariableTarget]::Machine)
