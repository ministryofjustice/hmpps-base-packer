$ErrorActionPreference = "Stop"
$VerbosePreference="Continue"

#--- Make
choco install make -y --version 4.2.1
#--- Install Non Sucking Service Manager
choco install nssm -y --version 2.24.101.20180116

#--- Chromedriver
choco install -y chromedriver --version 2.440
