$ErrorActionPreference = 'Stop'
$VerbosePreference = 'Continue'

try {

    ################################################################################
    # Get the Environment Name from ec2 meta data 
    ################################################################################
    $instanceid = Invoke-RestMethod "http://169.254.169.254/latest/meta-data/instance-id"
    # Get the environment name and application from this instance's environment-name and application tag values
    $environmentName = Get-EC2Tag -Filter @(
        @{
            name="resource-id"
            values="$instanceid"
        }
        @{
            name="key"
            values="environment-name"
        }
    )
   
    ################################################################################
    # Edit Cloudwatch Config to set log_group_name to specific name for this env
    ################################################################################
    $config = "C:\Setup\Cloudwatch\config.json"
    Write-Host("Editing Cloudwatch Config file '$config'")
    
    $loggroupnametext = '"log_group_name": "' + $environmentName.Value + '/IAPS/'
    Write-Host("Updating Cloudwatch Config log_group_name to '$loggroupnametext'")
    ((Get-Content -path $config -Raw) -replace '"log_group_name": "/IAPS/',$loggroupnametext) | Set-Content -Path $config

    ################################################################################
    # Update Cloudwatch Agent Config
    ################################################################################
    Write-Host ('Start the cloudwatch service')
    Start-Process powershell.exe -WorkingDirectory "C:\Program Files\Amazon\AmazonCloudWatchAgent" -Wait -ArgumentList ".\amazon-cloudwatch-agent-ctl.ps1 -a fetch-config -m ec2 -c file:$config -s"

}
catch [Exception] {
    Write-Host ('Failed to configure and start aws cloudwatch agent')
    echo $_.Exception|format-list -force
} 
