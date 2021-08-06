##########################################################################
# UPDATED TO INSTALL WEB AND API DEPENDING ON INSTANCE TAG
# THEREFORE DO NOT RUN IN PACKER BUILD BUT INSTEAD AT FIRST RUNTIME
##########################################################################

# $ErrorActionPreference = "Stop"
$VerbosePreference="Continue"
Set-ExecutionPolicy Bypass -Force

Write-Output('Start of InstallKarmaApp.ps1 ---->')

try {

    $key = 'HKLM:\Software\HMMPS'
    $instanceName = (Get-ItemProperty -Path $key -Name cporacleenvironmentname).cporacleenvironmentname
    $KarmaAPIVersion = (Get-ItemProperty -Path $key -Name karmawebversion).karmawebversion
    $KarmaWEBVersion = (Get-ItemProperty -Path $key -Name karmaapiversion).karmaapiversion

    if( $false -eq (Test-Path -Path "C:\setup")) {
        New-Item -Path "c:\" -Name "setup" -ItemType "directory"
    }

    # CHECK IF API OR WEB SERVER - build WEB by default
    if ($instanceName -Like "*api*"){

        Write-Output ('API instance detected, installing Karma API')
        $KarmaFileName = "${KarmaAPIVersion}.zip"
        $WebSitePath   = "c:\inetpub\${KarmaAPIVersion}"

    }else {

        Write-Output ('WEB instance detected, installing Karma Website')
        $KarmaFileName = "${KarmaWEBVersion}.zip"
        $WebSitePath   = "c:\inetpub\${KarmaWEBVersion}"

    }

    Write-Output "#----------------------------------------------------------------------"
    Write-Output "Extracting Karma Zip to '$WebSitePath'"
    Write-Output "#----------------------------------------------------------------------"
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    [System.IO.Compression.ZipFile]::ExtractToDirectory("c:\setup\$KarmaFileName", "$WebSitePath")

    Import-Module IISAdministration

    $WebSiteName = "CPOracle"
    $AppPoolName = "$WebSiteName"

    Get-IISSite
    Write-Output "----------------------------------------------"
    Write-Output "Removing Default Web Site"
    Write-Output "----------------------------------------------"
    Remove-IISSite -Name "Default Web Site" -Confirm:$false

    Write-Output "----------------------------------------------"
    Write-Output "Creating CPOracle Web Application"
    Write-Output "----------------------------------------------"
    $manager = Get-IISServerManager
    $site = $manager.Sites.Add("$WebSiteName", "http", "*:80:", "$WebSitePath")
    $site.Id = 1
    $manager.CommitChanges()

    Write-Output "----------------------------------------------"
    Write-Output "Creating $AppPoolName Application Pool"
    Write-Output "----------------------------------------------"
    $manager = Get-IISServerManager
    $pool = $manager.ApplicationPools.Add("$AppPoolName")
    $pool.ManagedPipelineMode = "Integrated"
    $pool.ManagedRuntimeVersion = "v4.0"
    $pool.Enable32BitAppOnWin64 = $false
    $pool.AutoStart = $true
    $pool.StartMode = "AlwaysRunning"
    $manager.CommitChanges()

    Write-Output "----------------------------------------------"
    Write-Output "Assigning Application Pool $AppPoolName to website $WebsiteName"
    Write-Output "----------------------------------------------"
    $manager = Get-IISServerManager
    $website = $manager.Sites["$WebsiteName"]
    $website.Applications["/"].ApplicationPoolName = "$AppPoolName"
    $manager.CommitChanges()

    Get-IISSite

    Write-Output "------------------------------------------------------------------------------------------"
    Write-Output "Adding karma.html to the top of default documents list for website $WebsiteName"
    Write-Output "------------------------------------------------------------------------------------------"
    $ConfigSection = Get-IISConfigSection -SectionPath "system.webServer/defaultDocument"
    $DefaultDocumentCollection = Get-IISConfigCollection -ConfigElement $ConfigSection -CollectionName "files"
    if ($cporacleServerType.Value -Like "*api*"){
        New-IISConfigCollectionElement -ConfigCollection $DefaultDocumentCollection -ConfigAttribute @{"Value" = "karma.html"} -AddAt 0


    }else {
        New-IISConfigCollectionElement -ConfigCollection $DefaultDocumentCollection -ConfigAttribute @{"Value" = "index.html"} -AddAt 0

    }
    Write-Output "----------------------------------------------"
    Write-Output "Enabling anonymousAuthentication on website $WebsiteName"
    Write-Output "----------------------------------------------"
    # The section paths are:
    #
    #  Anonymous: system.webServer/security/authentication/anonymousAuthentication
    #  Basic:     system.webServer/security/authentication/basicAuthentication
    #  Windows:   system.webServer/security/authentication/windowsAuthentication

    $manager = Get-IISServerManager
    $config = $manager.GetApplicationHostConfiguration()
    $section = $config.GetSection("system.webServer/security/authentication/anonymousAuthentication", "$WebsiteName")
    $section.Attributes["enabled"].Value = $true
    $manager.CommitChanges()

    Write-Output "----------------------------------------------"
    Write-Output "Configuring Logging on website $WebsiteName"
    Write-Output "----------------------------------------------"
    $manager = Get-IISServerManager
    $site = $manager.Sites["$WebsiteName"]
    $logFile = $site.LogFile
    $logFile.LogFormat = "W3c"               # Formats:   W3c, Iis, Ncsa, Custom
    $logFile.Directory = "C:\CPOracle\Logs"
    $logFile.Enabled = $true
    $logFile.Period = "Daily"
    $manager.CommitChanges()

    Write-Output('<---- End of of InstallKarmaApp.ps1')

}
catch [Exception] {
Write-Output ('Failed to install Karma Website or API')
echo $_.Exception|format-list -force
Exit 1
}

