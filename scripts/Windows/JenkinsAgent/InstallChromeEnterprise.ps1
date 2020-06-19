### Install google chrome 70.x enterprise
$ErrorActionPreference = "Stop"
$VerbosePreference="Continue"

choco install googlechrome -y -ignore-checksums --version 81.0.4044.129

# Create our master preference file
$fileData = @"
{
	"homepage": "http://www.google.com",
	"homepage_is_newtabpage": false,
	"browser": {
		"show_home_button": true,
		"check_default_browser": false,
		"window_placement": {
			"bottom": 1000,
			"left": 10,
			"maximized": false,
			"right": 904,
			"top": 10,
			"work_area_bottom": 1010,
			"work_area_left": 0,
			"work_area_right": 1680,
			"work_area_top": 0
		}
	},
	"bookmark_bar": {
		"show_on_all_tabs": true
	},
	"distribution": {
		"skip_first_run_ui": true,
		"show_welcome_page": false,
		"import_search_engine": false,
		"import_history": false,
		"create_all_shortcuts": true,
		"do_not_launch_chrome": true,
		"make_chrome_default": false,
		"suppress_first_run_default_browser_prompt": true
	}
}
"@

$fileData | Out-File -FilePath "C:\Program Files (x86)\Google\Chrome\Application\master_preferences"

# Turn our auto update cron off
New-Item -Path Registry::HKEY_LOCAL_MACHINE\Software\Policies\Google\Update `
                 -Name "AutoUpdateCheckPeriodMinutes" `
                 -Value "0" `
                 -Type DWord `
                 -Force

# disable update service
Stop-Service gupdate
Set-Service gupdate -StartupType Disabled

# Patch registry so that we don't update at all
Set-ItemProperty -Path Registry::HKEY_LOCAL_MACHINE\Software\Policies\Google\Update `
                 -Name "UpdateDefault" `
                 -Value "00000000" `
                 -Type DWord `
                 -Force

Set-ItemProperty -Path Registry::HKEY_LOCAL_MACHINE\Software\Wow6432Node\Google\Update `
                 -Name "UpdateDefault" `
                 -Value "00000000" `
                 -Type DWord `
                 -Force

Set-ItemProperty -Path Registry::HKEY_LOCAL_MACHINE\Software\Policies\Google\Update `
                 -Name "DisableAutoUpdateChecksCheckboxValue" `
                 -Value "00000001" `
                 -Type DWord `
                 -Force

Set-ItemProperty -Path Registry::HKEY_LOCAL_MACHINE\Software\Wow6432Node\Google\Update `
                 -Name "DisableAutoUpdateChecksCheckboxValue" `
                 -Value "00000001" `
                 -Type DWord `
                 -Force

Set-ItemProperty -Path Registry::HKEY_LOCAL_MACHINE\Software\Policies\Google\Update `
                 -Name "AutoUpdateCheckPeriodMinutes" `
                 -Value "00000000" `
                 -Type DWord `
                 -Force

Set-ItemProperty -Path Registry::HKEY_LOCAL_MACHINE\Software\Wow6432Node\Google\Update `
                 -Name "AutoUpdateCheckPeriodMinutes" `
                 -Value "00000000" `
                 -Type DWord `
                 -Force
