$ErrorActionPreference = "Stop"
$VerbosePreference="Continue"

Import-Module 'Carbon'
Import-Module psyaml
# Set our tls version for the script becuase IE engine...
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

if (-not (Test-Path env:TARGET_ENVIRONMENT)) {
    $env:TARGET_ENVIRONMENT = 'dev'
}

$url = "https://raw.githubusercontent.com/ministryofjustice/hmpps-delius-ansible/master/group_vars/$env:TARGET_ENVIRONMENT.yml"

#download our yaml file
Invoke-WebRequest -Uri "$url" -OutFile "$env:TEMP\users.yaml"

[string[]]$fileContent = Get-Content "$env:TEMP\users.yaml"
$content = ''
foreach ($line in $fileContent) {
    $content = $content + "`n" + $line
}

$yaml = ConvertFrom-YAML $content

#Add update users
foreach($user in $yaml.users) {
    $keyname = "/$env:TARGET_ENVIRONMENT/windows/rds/" + $user.username + "/password"
    $password = $(try{aws --region eu-west-2 ssm get-parameter --with-decryption --name $keyname } catch {$False})

    if ($password) {
        $password = $($password | jq .Parameter.Value)
    }

    if (-not $(try{Get-User -UserName $user.username} catch {$False})) {
        #If we don't have a password we generate one
        if(-not $password) {
            $passwordLen = (Get-Random -Minimum 32 -Maximum 64)
            $password = [System.Web.Security.Membership]::GeneratePassword($passwordLen, 10)
            aws --region eu-west-2 ssm put-parameter --name $keyname --type SecureString --value $password
        }
    }

    $creds = New-Credential -UserName $user.username -Password $password
    Install-User -Credential $creds -FullName $user.name

    if ($user.groups.Contains('wheel')) {
        Add-GroupMember -Name Administrators -Member $user.username
    }

    # Create home directory
    $securePassword = ConvertTo-SecureString $password -AsPlainText -Force
    $cred = New-Object System.Management.Automation.PSCredential -ArgumentList $user.username,$securePassword
    Start-Process cmd /c -WindowStyle Hidden -Credential $cred -ErrorAction SilentlyContinue

    #Create the .ssh directory and add our key to authorize_keys
    $userHome = "C:\Users\" + $user.username
    Install-Directory -Path "$userHome\.ssh"
    Set-Content -Path "$userHome\.ssh\authorized_keys" -Value $user.ssh_key

#    $acl = Get-Acl -Path $userHome
#    Set-Acl -LiteralPath "$userHome\.ssh" -AclObject $acl
}

#Remove users
foreach($user in $yaml.users_deleted) {
    if($(try{Get-User -UserName $user.username} catch {$False})) {
        Uninstall-User -Username $user.username
    }
}
