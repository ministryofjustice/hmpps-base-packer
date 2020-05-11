$ErrorActionPreference = "Stop"
$VerbosePreference="Continue"

Import-Module 'Carbon'

Uninstall-Directory -Path C:\temp -Recurse
