# $ErrorActionPreference = "Stop"
$VerbosePreference = "Continue"

try {

    # Get the instance id from ec2 meta data
    $instanceid = Invoke-RestMethod "http://169.254.169.254/latest/meta-data/instance-id"

    # Get the environment name from this instance's environment-name and application tag values
    $environmentName = Get-EC2Tag -Region eu-west-2 -Filter @(
        @{
            name="resource-id"
            values="$instanceid"
        }
        @{
            name="key"
            values="environment-name"
        }
    )
    $environmentName.Value


    # Get the Instance Name from this instance's environment-name and application tag values
    $cporacleServerType = Get-EC2Tag -Region eu-west-2 -Filter @(
        @{
            name="resource-id"
            values="$instanceid"
        }
        @{
            name="key"
            values="Name"
        }
    )
    $cporacleServerType.Value

    # CHECK IF API OR WEB SERVER - build WEB by default
    if ($cporacleServerType.Value -Contains "api"){
        Write-Output ('API server instance detected')

        Write-Output('Fetching CPOracle Configuration from SSM Parameter Store and existing RDS endpoint')

        Write-Output('Get the RDS Endpoint for the CPOracle Database')
        $RDSEndpoint=(aws rds describe-db-instances --db-instance-identifier 'cp-oracle-native-backup-restore' --query 'DBInstances[].Endpoint.Address' --output text)
        Write-Output("Using RDS Endpoint '" + $RDSEndpoint + "'")

        $cporacle_app_username_SSMPath = "/" + $environmentName.Value + "/cr/cporacle/rds/cporacle_app_username"
        Write-Output("get ssm param $cporacle_app_username_SSMPath")
        $cporacle_app_username = Get-SSMParameter -Name $cporacle_app_username_SSMPath -WithDecryption $true
        Write-Output("cporacle_app_username: " + $cporacle_app_username.Value)

        $cporacle_app_password_SSMPath = "/" + $environmentName.Value + "/cr/cporacle/rds/cporacle_app_password"
        Write-Output("get ssm param $cporacle_app_password_SSMPath")
        $cporacle_app_password = Get-SSMParameter -Name $cporacle_app_password_SSMPath -WithDecryption $true
        Write-Output("cporacle_app_password: " + $cporacle_app_password.Value)

        ###############################################################
        # Update API WEB Config File
        ###############################################################

        $configfile="C:\inetpub\Karma-1.0.226.666\Web.config"
        Write-Output("Updating CPOracle Config file '${configfile}'")

        $content = Get-Content -path $configfile
        $content.replace('$$RDSENDPOINT$$', $RDSEndpoint) | Set-Content $configfile

        $content = Get-Content -path $configfile
        $content.replace('$$RDSUSERNAME$$', $cporacle_app_username.Value) | Set-Content $configfile

        $content = Get-Content -path $configfile
        $content.replace('$$RDSPASSWORD$$', $cporacle_app_password.Value) | Set-Content $configfile

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
}
catch [Exception] {
    Write-Output ('Failed to update CPOracle Config')
    echo $_.Exception|format-list -force
    Exit 1
} 
 
