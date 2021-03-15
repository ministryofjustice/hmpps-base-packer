$ErrorActionPreference = 'Stop'
$VerbosePreference = 'Continue'

try {

    Import-Module Carbon

    $dir = "C:\Setup\BackupLogs"
    if(!(Test-Path -Path $dir )){
        New-Item -ItemType directory -Path $dir
        Write-Host "Backups Log folder created"
    }
    else
    {
      Write-Host "Backups Log Folder already exists"
    }

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

    $currentenv = ($environmentName.Value)
    Write-Output "The current environment is $currentenv"

    $action = New-ScheduledTaskAction -Execute 'Powershell.exe' -Argument '-NoProfile -WindowStyle Hidden -command "& powershell c:\Setup\Backup-IAPS-Configs.ps1 > c:\Setup\BackupLogs\backup.log"'
    $trigger = New-ScheduledTaskTrigger -Daily -At 9am
    Register-ScheduledTask -Action $action -Trigger $trigger -TaskName "IAPSDailyConfigBackup" -Description "Daily backup of IAPS Config Files to S3" -User "NT AUTHORITY\SYSTEM"

}
catch [Exception] {
    Write-Host ('Error: Failed to create Windows Scheduled Task to Backup IAPS config files to s3')
    echo $_.Exception|format-list -force
    #exit 1
} 
  