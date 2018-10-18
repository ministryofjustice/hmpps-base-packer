$ErrorActionPreference = "Stop"
$VerbosePreference="Continue"

Carbon_FirewallRule EnableSMBIn
{
    Name = 'Jenkins SMB Traffic'
    Action = 'Allow';
    Direction = 'In';
    Enabled = $true;
    Protocol = 'tcp';
    LocalPort = '445';
    Ensure = 'Present';
}
