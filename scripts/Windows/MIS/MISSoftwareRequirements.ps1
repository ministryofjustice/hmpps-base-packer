$ErrorActionPreference = "Stop"
$VerbosePreference="Continue"

#--- Visual C++ ----
choco install vcredist2012 vcredist2015 vcredist-all -y

#--- DotNet 4.5 ---
choco install dotnet3.5 dotnet4.5 dotnet4.5.2 -y
