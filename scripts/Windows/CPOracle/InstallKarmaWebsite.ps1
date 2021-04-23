# $ErrorActionPreference = "Stop"
$VerbosePreference="Continue"

Set-ExecutionPolicy Bypass -Force

if( $false -eq (Test-Path -Path "C:\setup")) {
    New-Item -Path "c:\" -Name "setup" -ItemType "directory"
}

Write-Output "#----------------------------------------------------------------------"
Write-Output "# Download Karma Binaries from S3 Bucket "
Write-Output "#----------------------------------------------------------------------"
# tf-eu-west-2-hmpps-eng-dev-artefacts-cporacle-s3bucket in eng-dev
$Bucket        = "tf-eu-west-2-hmpps-eng-dev-artefacts-cporacle-s3bucket"
$KarmaFileName = "karma-1.0.226.666.zip"

Write-Output "#----------------------------------------------------------------------"
Write-Output "Copying Karma Zip file from s3://$Bucket/$KarmaFileName"
Write-Output "#----------------------------------------------------------------------"
# aws s3 cp "s3://$Bucket/$KarmaFileName" c:\setup\$KarmaFileName
Copy-S3Object -BucketName $Bucket -Key "/$KarmaFileName" -DestinationKey c:\setup\$KarmaFileName


Write-Output "#----------------------------------------------------------------------"
Write-Output "Extracting Karma Zip to c:\inetpub"
Write-Output "#----------------------------------------------------------------------"
Add-Type -AssemblyName System.IO.Compression.FileSystem
[System.IO.Compression.ZipFile]::ExtractToDirectory("c:\\setup\\$KarmaFileName", "C:\\inetpub")

Import-Module IISAdministration

$WebSiteName = "CPOracle"
$WebSitePath = "c:\inetpub\karma-1.0.226.666"
$AppPoolName = "$WebSiteName"

Get-IISSite
Write-Output "----------------------------------------------"
Write-Output "Removing Default Web Site"
Write-Output "----------------------------------------------"
Remove-IISSite -Name "Default Web Site" -Force

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

