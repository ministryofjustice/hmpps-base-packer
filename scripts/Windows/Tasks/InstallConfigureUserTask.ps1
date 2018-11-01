$ErrorActionPreference = "Stop"
$VerbosePreference="Continue"

$scheduledAction  = New-ScheduledTaskAction `
                    -Execute "PowerShell.exe" `
                    -Argument "C:\ProgramData\ConfigureSSHUsers.ps1"

$scheduledTrigger = New-ScheduledTaskTrigger `
                    -Once `
                    -At (Get-Date) `
                    -RepetitionInterval (New-TimeSpan -Minutes 10) `
                    -RepetitionDuration ([System.TimeSpan]::MaxValue)

$scheduledTask    = Register-ScheduledTask `
                    -TaskName "ManageUsers" `
                    -Trigger $scheduledTrigger `
                    -User "System" `
                    -Action $scheduledAction
