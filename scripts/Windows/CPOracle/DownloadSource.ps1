
$VerbosePreference="Continue"
Set-ExecutionPolicy Bypass -Force

Write-Output('Start of DownloadSource.ps1 ---->')

if( $false -eq (Test-Path -Path "C:\setup")) {
New-Item -Path "c:\" -Name "setup" -ItemType "directory"
}

Write-Output "#----------------------------------------------------------------------"
Write-Output "# Download CPOracle API Binaries from S3 Bucket "
Write-Output "#----------------------------------------------------------------------"

##### UPDATE $KarmaAPIVersion with the API release to deploy #####
$KarmaAPIVersion   = "LondonCrc.Karma.API.2021.06.03.10.43"
Write-Output ("Will download Karma API version: ${KarmaAPIVersion}")
$KarmaAPIFileName = "${KarmaAPIVersion}.zip"

Write-Output "#----------------------------------------------------------------------"
Write-Output "Copying Karma Zip file from s3://$Bucket/$KarmaFileName"
Write-Output "#----------------------------------------------------------------------"
Read-S3Object -BucketName tf-eu-west-2-hmpps-eng-dev-artefacts-cporacle-s3bucket -Key /$KarmaAPIFileName -File c:\setup\$KarmaAPIFileName -Region eu-west-2

New-Item -Path HKLM:\Software\HMMPS -Name karmaapiversion –Force -Value “$KarmaAPIVersion”

##### UPDATE $KarmaWEBVersion with the Website release to deploy #####
$KarmaWEBVersion   = "LondonCrc.Karma.Website.2021.06.04.14.40"
Write-Output ("Will download Karma WEB version: ${KarmaWEBVersion}")
$KarmaWEBFileName = "${KarmaWEBVersion}.zip"

Write-Output "#----------------------------------------------------------------------"
Write-Output "Copying Karma Zip file from s3://$Bucket/$KarmaFileName"
Write-Output "#----------------------------------------------------------------------"
Read-S3Object -BucketName tf-eu-west-2-hmpps-eng-dev-artefacts-cporacle-s3bucket -Key /$KarmaWEBFileName -File c:\setup\$KarmaWEBFileName -Region eu-west-2

New-Item -Path HKLM:\Software\HMMPS -Name karmawebversion –Force -Value “$KarmaWEBVersion”

Write-Output('<---- End of of DownloadSource.ps1')