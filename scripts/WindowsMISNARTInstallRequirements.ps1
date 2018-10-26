$ErrorActionPreference = "Stop"
$VerbosePreference="Continue"

#--- Visual C++ ----
choco install vcredist2012 -y

#--- DotNet 4.5 ---
choco install dotnet4.5 dotnet4.5.2 -y
