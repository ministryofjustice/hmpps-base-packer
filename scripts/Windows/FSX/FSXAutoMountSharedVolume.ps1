$ErrorActionPreference = "Stop"
$VerbosePreference = "Continue"

try {
    
    ###############################################################
    # Get creds from ParameterStore for this environment to connect
    ###############################################################
    Write-Host('Fetching IAPS Delius Credentials from SSM Parameter Store')
    # Get the instance id from ec2 meta data
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
    $application = Get-EC2Tag -Filter @(
        @{
            name="resource-id"
            values="$instanceid"
        }
        @{
            name="key"
            values="application"
        }
    ) 

    ################################
    # /mis-activedirectory/ad/ad_admin_username
    # /mis-activedirectory/ad/ad_admin_password
    ################################
    $ADUsername_SSMPath = "/" + $environmentName.Value + "/" + $application.Value + "/mis-activedirectory/ad/ad_admin_username"
    Write-Host("get ssm param $ADUsername")
    $ADUsername = Get-SSMParameter -Name $ADUsername_SSMPath -WithDecryption $true

    $ADPassword_SSMPath = "/" + $environmentName.Value + "/" + $application.Value + "mis-activedirectory/ad/ad_admin_password"
    Write-Host("get ssm param $ADPassword")
    $ADPassword = Get-SSMParameter -Name $ADPassword_SSMPath -WithDecryption $true
    
    ###############################################################
    # Map FSX Network Drive
    ###############################################################
    $FullADUserName     = "$ADUsername\$ADPassword"
    $SecureADPassword = ConvertTo-SecureString $ADPassword -AsPlainText -Force
    $cred =  New-Object -TypeName PSCredential -ArgumentList $FullADUserName, $SecureADPassword

    # TODO: Dynamically get FileSystemDNSName 
    $FSXFileSystemDNSName = "amznfsxngjronbd.delius-mis-dev.internal"
    New-PSDrive -Name "S" -Root "$FSXFileSystemDNSName\share" -Persist -PSProvider "FileSystem" -Credential $cred

}
catch [Exception] {
    Write-Host ('Failed to install IM Interface service')
    echo $_.Exception|format-list -force
    Exit 1
}