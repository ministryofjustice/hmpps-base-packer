echo "salt bootstrap start"

c:\salt\salt-minion.bat /S /master=salt

timeout /t 30 /nobreak

rmdir /s /q c:\salt\states

git clone -b issue-1 https://github.com/ministryofjustice/hmpps-mis-saltstack-states.git c:\salt\states

copy C:\salt\states\bootstrap\minion.conf C:\salt\conf\minion.d\minion.conf

rmdir /s /q c:\salt\states

net stop salt-minion

net start salt-minion

C:\salt\salt-call.bat pkg.refresh_db
C:\salt\salt-call.bat state.highstate

echo "salt bootstrap end"
