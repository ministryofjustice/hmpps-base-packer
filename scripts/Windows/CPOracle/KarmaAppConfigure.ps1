# $ErrorActionPreference = "Stop"
$VerbosePreference = "Continue"

try {

    Write-Output('Start of KarmaAppConfigure.ps1 ---->')

    $key = "HKLM:\Software\HMPPS"
    $instanceName = (Get-ItemProperty -Path $key -Name "cporacleinstancename").cporacleinstancename
    $environmentName = (Get-ItemProperty -Path $key -Name "cporacleenvironmentname").cporacleenvironmentname
    $RDSEndpoint = (Get-ItemProperty -Path $key -Name "rdsendpoint").rdsendpoint
    $cporacle_app_username = (Get-ItemProperty -Path $key -Name "cporacleappuser").cporacleappuser
    $cporacle_app_password = (Get-ItemProperty -Path $key -Name "cporacleapppw").cporacleapppw
    $KarmaAPIVersion = (Get-ItemProperty -Path $key -Name "karmaapiversion").karmaapiversion
    $KarmaWEBVersion = (Get-ItemProperty -Path $key -Name "karmawebversion").karmawebversion
    $EncryptionKeyPath = (Get-ItemProperty -Path $key -Name "cporaclekeypath").cporaclekeypath

    # CHECK IF API OR WEB SERVER - build WEB by default
    if ($instanceName -Like "*api*"){

        ###############################################################
        # Update API WEB Config File
        ###############################################################

        # Sets RDS DB details
        $configfile="C:\inetpub\$KarmaAPIVersion\Web.config"
        Write-Output("Updating CPOracle Config file '${configfile}'")

        $content = Get-Content -path $configfile
        $content.replace('$$RDSENDPOINT$$', $RDSEndpoint) | Set-Content $configfile

        $content = Get-Content -path $configfile
        $content.replace('$$RDSUSERNAME$$', $cporacle_app_username) | Set-Content $configfile

        $content = Get-Content -path $configfile
        $content.replace('$$RDSPASSWORD$$', $cporacle_app_password) | Set-Content $configfile

        $content = Get-Content -path $configfile
        $content.replace('$$ENCRYPTIONPATH$$', $EncryptionKeyPath) | Set-Content $configfile

        # Sets the flag to enable or disable password reset emails
        # Sets the flag to enable or disable test banner
        # Sets initial internal DB PWD for API user
        if ($environmentName -Like "*dev*"){
            Write-Output("Dev detected, setting banner and disabling password reset emails")

            $content = Get-Content -path $configfile
            $content.replace('$$PWDRESETEMAILS$$', 'false') | Set-Content $configfile

            $content = Get-Content -path $configfile
            $content.replace('$$DEVBANNER$$', 'true') | Set-Content $configfile

            # Sets instance name (cosmetic, not functionally needed)
            $content = Get-Content -path $configfile
            $content.replace('$$INSTANCE$$', 'dev instance') | Set-Content $configfile

            # Unknown development reason for hardcoded different initial password here:
            $content = Get-Content -path $configfile
            $content.replace('$$INITCREATEUSERPASSWORD$$', 'P8aXbferf;djbgtrpojnbiolg5sjOqq7u') | Set-Content $configfile

        }else {
            Write-Output("Prod detected, enabling password reset emails")

            $content = Get-Content -path $configfile
            $content.replace('$$PWDRESETEMAILS$$', 'true') | Set-Content $configfile

            $content = Get-Content -path $configfile
            $content.replace('$$DEVBANNER$$', 'false') | Set-Content $configfile

            # Sets instance name (cosmetic, not functionally needed)
            $content = Get-Content -path $configfile
            $content.replace('$$INSTANCE$$', 'prod instance') | Set-Content $configfile

            $content = Get-Content -path $configfile
            $content.replace('$$INITCREATEUSERPASSWORD$$', $cporacle_app_password) | Set-Content $configfile
        }

        $content = Get-Content -path $configfile
        $content

        ###############################################################
        # Restart W3SVC service
        ###############################################################
        Write-Output("Restarting W3SVC service..")
        $service = Restart-Service -Name W3SVC -Force -PassThru
        if ($service.Status -match "Running") {
            Write-Output('Restart of W3SVC successful')
        } else {
            Write-Output('Error - Failed to restart W3SVC - see logs')
            Exit 1
        }


    }else {

        Write-Output ('WEB server instance detected')

        ###############################################################
        # Set index.html as default site
        ###############################################################
        Write-Output("Setting index.html to be default document..")
        Remove-WebConfigurationProperty  -pspath 'MACHINE/WEBROOT/APPHOST/CPOracle'  -filter "system.webServer/defaultDocument/files" -name "." -AtElement @{value='karma.html'}
        Remove-WebConfigurationProperty  -pspath 'MACHINE/WEBROOT/APPHOST/CPOracle'  -filter "system.webServer/defaultDocument/files" -name "." -AtElement @{value='Default.htm'}
        Remove-WebConfigurationProperty  -pspath 'MACHINE/WEBROOT/APPHOST/CPOracle'  -filter "system.webServer/defaultDocument/files" -name "." -AtElement @{value='Default.asp'}
        Remove-WebConfigurationProperty  -pspath 'MACHINE/WEBROOT/APPHOST/CPOracle'  -filter "system.webServer/defaultDocument/files" -name "." -AtElement @{value='index.htm'}
        Remove-WebConfigurationProperty  -pspath 'MACHINE/WEBROOT/APPHOST/CPOracle'  -filter "system.webServer/defaultDocument/files" -name "." -AtElement @{value='iisstart.htm'}
        Remove-WebConfigurationProperty  -pspath 'MACHINE/WEBROOT/APPHOST/CPOracle'  -filter "system.webServer/defaultDocument/files" -name "." -AtElement @{value='default.aspx'}

        ###############################################################
        # Set 404 errors to point to index.html
        ###############################################################
        Write-Output("Customizing 404 errors to point to index.html..")
        #Set-WebConfigurationProperty -pspath 'MACHINE/WEBROOT/APPHOST/CPOracle'  -filter "system.webServer/httpErrors/error[@statusCode='404' and @subStatusCode='-1']" -name "prefixLanguageFilePath" -value "%SystemDrive%\inetpub\custerr"
        Set-WebConfigurationProperty -pspath 'MACHINE/WEBROOT/APPHOST/CPOracle'  -filter "system.webServer/httpErrors/error[@statusCode='404' and @subStatusCode='-1']" -name "path" -value "/index.html"
        Set-WebConfigurationProperty -pspath 'MACHINE/WEBROOT/APPHOST/CPOracle'  -filter "system.webServer/httpErrors/error[@statusCode='404' and @subStatusCode='-1']" -name "responseMode" -value "ExecuteURL"

        ###############################################################
        # Restart W3SVC service
        ###############################################################
        Write-Output("Restarting W3SVC service..")
        $service = Restart-Service -Name W3SVC -Force -PassThru
        if ($service.Status -match "Running") {
            Write-Output('Restart of W3SVC successful')
        } else {
            Write-Output('Error - Failed to restart W3SVC - see logs')
            Exit 1
        }
    }

    Write-Output('<---- End of of KarmaAppConfigure.ps1')
}
catch [Exception] {
    Write-Output ('Failed to update CPOracle Config')
    echo $_.Exception|format-list -force
    Exit 1
} 
 
