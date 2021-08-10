$VerbosePreference = "Continue"

try {

    # Get the instance id from ec2 meta data
    $instanceid = Invoke-RestMethod "http://169.254.169.254/latest/meta-data/instance-id"

    # Get the environment name from this instance's environment-name and application tag values
    $environmentName = Get-EC2Tag -Region eu-west-2 -Filter @(
    @{
    name="resource-id"
    values="$instanceid"
    }
    @{
    name="key"
    values="environment-name"
    }
    )
    $environmentName.Value


    # Get the Instance Name from this instance's environment-name and application tag values
    $instanceName = Get-EC2Tag -Region eu-west-2 -Filter @(
    @{
    name="resource-id"
    values="$instanceid"
    }
    @{
    name="key"
    values="Name"
    }
    )
    $instanceName.Value

    New-Item -Path HKLM:\Software\HMMPS -Name cporacleenvironmentname -Force -Value “$environmentName.Value”
    New-Item -Path HKLM:\Software\HMMPS -Name cporacleinstancename -Force -Value “$instanceName.Value”

}
catch [Exception] {
    Write-Output ('Failed to write new registry keys')
    echo $_.Exception|format-list -force
    Exit 1
}

