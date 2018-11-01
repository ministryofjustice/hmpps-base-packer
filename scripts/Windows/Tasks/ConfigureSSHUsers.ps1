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

foreach($group in $yaml.groups_to_create) {
    if(-not (Get-Group -Name ${group.name})) {
        Install-Group -Name $group.name
    }
}

foreach($user in $yaml.users) {
    $keyname = "/$env:TARGET_ENVIRONMENT/${user['username']}/windows/rds/password"

    if (-not (Get-User -Name ${user['username']})) {
        #If we don't have a password we generate one
        if(-not $password) {
            $passwordLen = (Get-Random -Minimum 32 -Maximum 64)
            $password = [System.Web.Security.Membership]::GeneratePassword($passwordLen, 10)
            aws --region eu-west-2 ssm put-parameter --name $keyname --type SecureString --value $password
        }

    } else {
        $password = aws --region eu-west-2 ssm get-parameter --with-decryption --name $keyname --query Parameters[0].Value
    }

    $creds = New-Credentials -User $user['username'] -Password $password
    Install-User -Credentials $creds -FullName "$user['name']"
    if ($user['groups'] contains 'wheel') {
        Add-GroupMember -Name Administrators -Member "$user['username']"
    }
    foreach ($group in $user['groups]) {
        if ($group -ne 'adm' || $group -ne 'wheel') {
            Add-GroupMember -Name $group -Member "$user['username']"

        }
    }

}