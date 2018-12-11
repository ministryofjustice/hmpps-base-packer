$ErrorActionPreference = "Stop"
$VerbosePreference="Continue"

#--- Make
choco install make -y
#--- Install Non Sucking Service Manager
choco install nssm -y

#--- Chromedriver
choco install -y chromedriver --version 2.440
