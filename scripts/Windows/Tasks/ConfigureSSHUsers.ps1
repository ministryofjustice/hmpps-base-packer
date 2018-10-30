import-module psyaml

if (-not (Test-Path env:TARGET_ENVIRONMENT)) {
    $env:TARGET_ENVIRONMENT = 'dev'
}

$url = "https://github.com/ministryofjustice/hmpps-delius-ansible/blob/master/group_vars/$env:TARGET_ENVIRONMENT.yml"

#download our yaml file
Invoke-WebRequest -Uri "$url" -OutFile "$env:TEMP\users.yaml"

[string[]]$fileContent = Get-Content "$env:TEMP\users.yaml"
$content = ''
foreach ($line in $fileContent) {
    $content = $content + "`n" + $line
}

$yaml = ConvertFrom-YAML $content

