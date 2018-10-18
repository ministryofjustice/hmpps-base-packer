$ErrorActionPreference = "Stop"
$VerbosePreference="Continue"

# disable UAC prompts
#`Set-R egistryKeyValue -Path hklm:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System -Name 'ConsentPromptBehaviorAdmin' -DWord 0`
Set-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System" -Name "ConsentPromptBehaviorAdmin" -Value "0"
Set-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System" -Name "ConsentPromptBehaviorUser" -Value "0"
Set-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System" -Name "EnableLUA" -Value "1"
Set-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System" -Name "PromptOnSecureDesktop" -Value "0"
#Set-RegistryKeyValue hklm:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System -Name 'ConsentPromptBehaviorAdmin' -DWord 0
