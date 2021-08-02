##########################################################################
# UPDATED TO INSTALL WEB AND API DEPENDING ON INSTANCE TAG
# THEREFORE DO NOT RUN IN PACKER BUILD BUT INSTEAD AT FIRST RUNTIME
##########################################################################

# $ErrorActionPreference = "Stop"
$VerbosePreference="Continue"
Set-ExecutionPolicy Bypass -Force


try {

    # Get the instance id from ec2 meta data
    $instanceid = Invoke-RestMethod "http://169.254.169.254/latest/meta-data/instance-id"

    if( $false -eq (Test-Path -Path "C:\setup")) {
        New-Item -Path "c:\" -Name "setup" -ItemType "directory"
    }

    # Get the Instance Name from this instance's environment-name and application tag values
    $cporacleServerType = Get-EC2Tag -Region eu-west-2 -Filter @(
        @{
            name="resource-id"
            values="$instanceid"
        }
        @{
            name="key"
            values="Name"
        }
    )
    $cporacleServerType.Value

    Write-Output "#----------------------------------------------------------------------"
    Write-Output "# Download CPOracle API Binaries from S3 Bucket "
    Write-Output "#----------------------------------------------------------------------"

    # CHECK IF API OR WEB SERVER - build WEB by default
    if ($cporacleServerType.Value -Contains "api"){

        Write-Output ('API instance detected, installing Karma API')
        ##### UPDATE $KarmaAPIVersion with the API release to deploy #####
        $KarmaAPIVersion   = "LondonCrc.Karma.API.2021.06.03.10.43"
        $KarmaFileName = "${KarmaAPIVersion}.zip"
        $WebSitePath   = "c:\inetpub\${KarmaAPIVersion}"

    }else {

        Write-Output ('WEB instance detected, installing Karma Website')
        ##### UPDATE $KarmaWEBVersion with the Website release to deploy #####
        $KarmaWEBVersion   = "LondonCrc.Karma.Website.2021.06.04.14.40"
        $KarmaFileName = "${KarmaWEBVersion}.zip"
        $WebSitePath   = "c:\inetpub\${KarmaWEBVersion}"

    }

    Write-Output "#----------------------------------------------------------------------"
    Write-Output "Copying Karma Zip file from s3://$Bucket/$KarmaFileName"
    Write-Output "#----------------------------------------------------------------------"
    Read-S3Object -BucketName tf-eu-west-2-hmpps-eng-dev-artefacts-cporacle-s3bucket -Key /$KarmaFileName -File c:\setup\$KarmaFileName -Region eu-west-2

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
    New-IISConfigCollectionElement -ConfigCollection $DefaultDocumentCollection -ConfigAttribute @{"Value" = "karma.html"} -AddAt 0

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

}
catch [Exception] {
Write-Output ('Failed to install Karma Website or API')
echo $_.Exception|format-list -force
Exit 1
}

