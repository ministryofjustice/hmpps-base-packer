### REMOVE AWS CLI ###
Write-Output('Removing AWS CLI')
$MyApp = Get-WmiObject -Class Win32_Product | Where-Object{$_.Name -eq "AWS Command Line Interface v2"}
$MyApp.Uninstall()
Write-Output('Finished removing AWS CLI')
### FINISH REMOVING AWS CLI ###