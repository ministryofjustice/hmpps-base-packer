# $ErrorActionPreference = "Stop"
$VerbosePreference = "Continue"

try {

    Write-Output('Start of KarmaAppConfigure.ps1 ---->')

    $key = 'HKLM:\Software\HMMPS'
    $instanceName = (Get-ItemProperty -Path $key -Name cporacleinstancename).cporacleenvironmentname
    $RDSEndpoint = (Get-ItemProperty -Path $key -Name rdsendpoint).rdsendpoint
    $cporacle_app_username = (Get-ItemProperty -Path $key -Name cporacleappuser).cporacleappuser
    $cporacle_app_password = (Get-ItemProperty -Path $key -Name cporacleapppw).cporacleapppw

    # CHECK IF API OR WEB SERVER - build WEB by default
    if ($instanceName -Like "*api*"){

        ###############################################################
        # Update API WEB Config File
        ###############################################################

        $configfile="C:\inetpub\${KarmaAPIVersion}\Web.config"
        Write-Output("Updating CPOracle Config file '${configfile}'")

        $content = Get-Content -path $configfile
        $content.replace('$$RDSENDPOINT$$', $RDSEndpoint) | Set-Content $configfile

        $content = Get-Content -path $configfile
        $content.replace('$$RDSUSERNAME$$', $cporacle_app_username) | Set-Content $configfile

        $content = Get-Content -path $configfile
        $content.replace('$$RDSPASSWORD$$', $cporacle_app_password) | Set-Content $configfile

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
 
