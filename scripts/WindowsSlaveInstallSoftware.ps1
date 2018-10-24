$ChocoInstallPath = "$env:SystemDrive\ProgramData\Chocolatey\bin"
$ErrorActionPreference = "Stop"
$VerbosePreference="Continue"

Add-Type -AssemblyName System.IO.Compression.FileSystem

if (!(Test-Path $ChocoInstallPath)) {
    iex ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1'))
}

#--- Git ---
choco install git make -y
#--- JDK 8 ---
$javaDir = "C:\\java8"
choco install jdk8 -params "installdir=$javaDir" -y
[System.Environment]::SetEnvironmentVariable('JAVA_HOME', "$javaDir", [System.EnvironmentVariableTarget]::Machine)
# Set Java memory limits
[System.Environment]::SetEnvironmentVariable('JAVA_OPTS',  '-Xms6144m -Xmx12288m', [System.EnvironmentVariableTarget]::Machine)
[System.Environment]::SetEnvironmentVariable('_JAVA_OPTS',  '-Xms6144m -Xmx12288m', [System.EnvironmentVariableTarget]::Machine)

$env:JAVA_HOME="$javaDir"
RefreshEnv

#--- Download & Install Maven
$url = "http://mirror.vorboss.net/apache/maven/maven-3/3.5.4/binaries/apache-maven-3.5.4-bin.zip"
$output = "C:\maven.zip"
$maven_dir = "C:\\maven"
echo "Downloading $url to install to $maven_dir"
$wc = New-Object System.Net.WebClient
$wc.DownloadFile($url, $output)
[System.IO.Compression.ZipFile]::ExtractToDirectory("$output", "C:\\")
#Rename to something clean
Rename-Item -Path "C:\\apache-maven-3.5.4" -NewName "$maven_dir"
#Add maven to env and path
[System.Environment]::SetEnvironmentVariable('M2_HOME', "$maven_dir", [System.EnvironmentVariableTarget]::Machine)
[System.Environment]::SetEnvironmentVariable('MAVEN_HOME', "$maven_dir", [System.EnvironmentVariableTarget]::Machine)
$env:MAVEN_HOME="C:\\maven"
RefreshEnv
[System.Environment]::SetEnvironmentVariable("Path", $env:Path + ";%MAVEN_HOME%\bin;%JAVA_HOME%\bin", [EnvironmentVariableTarget]::Machine)

#--- Install Non Sucking Service Manager
choco install nssm -y

#--- Download firefox
$url = "https://ftp.mozilla.org/pub/firefox/releases/52.9.0esr/win64/en-US/Firefox%20Setup%2052.9.0esr.exe"
$output = "$env:temp\setup.exe"

$wc = New-Object System.Net.WebClient
$wc.DownloadFile($url, $output)
& "$env:temp\setup.exe" -ms /INI=c:\temp\firefox.ini
