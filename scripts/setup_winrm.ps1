### Pinched from https://github.com/SkeltonThatcher/packer-bamboo/blob/master/scripts/SetUpWinRM.ps1

<powershell>

write-output "Running User Data Script"
write-host "(host) Running User Data Script"

winrm quickconfig -q
winrm set winrm/config/winrs '@{MaxMemoryPerShellMB="300"}'
winrm set winrm/config '@{MaxTimeoutms="1800000"}'
winrm set winrm/config/service '@{AllowUnencrypted="true"}'
winrm set winrm/config/service/auth '@{Basic="true"}'

netsh advfirewall firewall add rule name="WinRM 5985" protocol=TCP dir=in localport=5985 action=allow
netsh advfirewall firewall add rule name="WinRM 5986" protocol=TCP dir=in localport=5986 action=allow

net stop winrm
sc config winrm start=auto
net start winrm

Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope LocalMachine

</powershell>
