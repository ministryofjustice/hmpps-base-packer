$ErrorActionPreference = "Stop"
$VerbosePreference="Continue"

# Host entry
Add-Content -Path C:\Windows\System32\Drivers\etc\hosts -Value "172.26.243.12 salt"

RefreshEnv

#--- Git ----
choco install git -y

#--- jdk ----
choco install jdk8 -y

#--- Visual C++ ----
choco install vcredist2012 -y

#--- Python 3 and Miniconda
choco install python3 miniconda3 -y

RefreshEnv

#conda install pygit python=3
