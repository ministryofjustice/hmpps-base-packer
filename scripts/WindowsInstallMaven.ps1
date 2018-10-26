$ErrorActionPreference = "Stop"
$VerbosePreference="Continue"
Add-Type -AssemblyName System.IO.Compression.FileSystem

#--- Download & Install Maven
$url = "http://mirror.vorboss.net/apache/maven/maven-3/3.5.4/binaries/apache-maven-3.5.4-bin.zip"
$output = "C:\maven.zip"
$maven_dir = "C:\maven"
echo "Downloading $url to install to $maven_dir"
$wc = New-Object System.Net.WebClient
$wc.DownloadFile($url, $output)
[System.IO.Compression.ZipFile]::ExtractToDirectory("$output", "C:\\")
#Rename to something clean
Rename-Item -Path "C:\\apache-maven-3.5.4" -NewName "$maven_dir"
#Add maven to env and path
[System.Environment]::SetEnvironmentVariable('M2_HOME', "$maven_dir", [System.EnvironmentVariableTarget]::Machine)
[System.Environment]::SetEnvironmentVariable('MAVEN_HOME', "$maven_dir", [System.EnvironmentVariableTarget]::Machine)
$env:MAVEN_HOME="$maven_dir"
[System.Environment]::SetEnvironmentVariable("Path", $env:Path + ";%MAVEN_HOME%\bin", [EnvironmentVariableTarget]::Machine)

