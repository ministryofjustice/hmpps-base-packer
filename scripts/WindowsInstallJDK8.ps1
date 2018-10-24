$ErrorActionPreference = "Stop"
$VerbosePreference="Continue"

#--- JDK 8 ---
$javaDir = "C:\\java8"
choco install jdk8 -params "installdir=$javaDir" -y
[System.Environment]::SetEnvironmentVariable('JAVA_HOME', $javaDir, [System.EnvironmentVariableTarget]::Machine)
# Set Java memory limits
[System.Environment]::SetEnvironmentVariable('JAVA_OPTS',  '-Xms6144m -Xmx12288m', [System.EnvironmentVariableTarget]::Machine)
[System.Environment]::SetEnvironmentVariable('_JAVA_OPTS',  '-Xms6144m -Xmx12288m', [System.EnvironmentVariableTarget]::Machine)
[System.Environment]::SetEnvironmentVariable("Path", $env:Path + ";%JAVA_HOME%\bin", [EnvironmentVariableTarget]::Machine)