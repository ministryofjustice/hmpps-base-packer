$ErrorActionPreference = 'Stop'
$VerbosePreference = 'Continue'

# Download and install cloudwatch agent
try {
    $localPath = "C:\Setup\Cloudwatch"
    if (! (Test-Path -Path C:\Setup\Cloudwatch) ) {
        New-Item -Path "C:\Setup" -Name 'Cloudwatch' -ItemType 'directory'
    }
    $url = "s3://tf-eu-west-2-hmpps-eng-dev-artefacts-s3bucket/mis/installers/amazon-cloudwatch-agent.msi"
    Invoke-WebRequest -Uri $url -OutFile "$localPath\$file"

    Write-Host ('Installing MSI')
    Start-Process msiexec.exe -Wait -ArgumentList "/I $localPath\$file /quiet"  

}
catch [Exception] {
    Write-Host ('Failed to install aws cloudwatch agent')
    echo $_.Exception|format-list -force
    #exit 1
}