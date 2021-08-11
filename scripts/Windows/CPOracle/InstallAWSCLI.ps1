# Currently AWS CLI is needed to get the rds endpoint

### INSTALL AWS CLI ###
Write-Output('Installing AWS CLI')
Invoke-WebRequest -Uri https://awscli.amazonaws.com/AWSCLIV2.msi -Outfile "C:\aws.msi"
Start-Process -Wait -FilePath msiexec -ArgumentList /i, "c:\aws.msi", /qn
Remove-Item "c:\aws.msi"
Write-Output('Finished installing AWS CLI')

#Write-Output('Updating Enviromental Variables')
#$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

### FINISH INSTALLING AWS CLI ###