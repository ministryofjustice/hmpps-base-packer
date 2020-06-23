$ErrorActionPreference = "Stop"
$VerbosePreference="Continue"

#--- Make
choco install make -y --version 4.3

#--- Install Non Sucking Service Manager
choco install nssm -y --version 2.24.101.20180116

#--- Chromedriver
choco install -y chromedriver --version 2.440

#--- AWS CLI
choco install -y awscli --version 2.0.10
