$ChocoInstallPath = "$env:SystemDrive\ProgramData\Chocolatey\bin"

if (!(Test-Path $ChocoInstallPath)) {
    iex ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1'))
}

#---- TEMPORARY ---
Disable-UAC

#--- Python ---
choco install python2 -y
#--- JDK 8 ---
choco install jdk8 -y
#--- Maven and gradle
choco install maven gradle -y

#--- Restore Temporary Settings ---
Enable-UAC
