$ChocoInstallPath = "$env:SystemDrive\ProgramData\Chocolatey\bin"
$ErrorActionPreference = "Stop"
$VerbosePreference="Continue"

if (!(Test-Path $ChocoInstallPath)) {
    iex ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1'))
}

#--- Python ---
choco install python2 -y
#--- JDK 8 ---
choco install jdk8 make -y
#--- Maven and gradle
choco install maven gradle -y
#--- Salt because windows ---
choco install saltminion -y

##Salt stuff
& "salt-call --local pkg.list_available firefox"