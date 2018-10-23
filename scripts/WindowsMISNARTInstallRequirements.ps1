$ErrorActionPreference = "Stop"
$VerbosePreference="Continue"

# Host entry
#Add-Content -Path C:\Windows\System32\Drivers\etc\hosts -Value "172.26.243.12 salt"


#--- awscli ---
choco install awscli -y

RefreshEnv

#--- Salt Minion ----
choco install saltminion -y

#--- Git ----
choco install git -y

#--- jdk ----
choco install jdk8 -y

#--- Visual C++ ----

choco install vcredist2012 -y

RefreshEnv

echo "salt bootstrap start"

c:\tmp\salt-minion.exe /S /master=salt

timeout /t 30 /nobreak

rmdir /s /q c:\salt\states

git clone -b issue-1 https://github.com/ministryofjustice/hmpps-mis-saltstack-states.git c:\salt\states

copy C:\salt\states\bootstrap\minion.conf C:\salt\conf\minion.d\minion.conf

rmdir /s /q c:\salt\states

net stop salt-minion

net start salt-minion

salt-call pkg.refresh_db; salt-call state.highstate

echo "salt bootstrap end"
