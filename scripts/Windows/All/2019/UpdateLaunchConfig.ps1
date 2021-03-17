$launchConfig = Get-Content -Path C:\ProgramData\Amazon\EC2-Windows\Launch\Config\LaunchConfig.json | ConvertFrom-Json

# Update Administrator Password to the one we pass into the Packer Build from SSM ParameterStore
$launchConfig.adminPasswordType = 'Specify'
$launchConfig.adminPassword     = "$env:WIN_ADMIN_PASS"
# set the computername property
$launchConfig.setComputerName = 'True'
$launchConfig

Set-Content -Value ($launchConfig | ConvertTo-Json) -Path C:\ProgramData\Amazon\EC2-Windows\Launch\Config\LaunchConfig.json