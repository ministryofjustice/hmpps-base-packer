$ErrorActionPreference = "Stop"
$VerbosePreference="Continue"

try
{
    $EC2SettingsFile="C:\Program Files\Amazon\Ec2ConfigService\Settings\Config.xml"
    $xml = [xml](get-content $EC2SettingsFile)
    $xmlElement = $xml.get_DocumentElement()
    $xmlElementToModify = $xmlElement.Plugins

    if (Test-Path -Path $EC2SettingsFile)
    {
        foreach ($element in $xmlElementToModify.Plugin)
        {
            if ($element.name -eq "Ec2HandleUserData")
            {
                $element.State = "Enabled"
            }
        }
        $xml.Save($EC2SettingsFile)
    } else {
        $fileContents = @"
    <?xml version="1.0" encoding="utf-8"?>
    <Ec2ConfigurationSettings>
      <Plugins>
        <Plugin>
          <Name>Ec2SetPassword</Name>
          <State>Disabled</State>
        </Plugin>
        <Plugin>
          <Name>Ec2SetComputerName</Name>
          <State>Disabled</State>
        </Plugin>
        <Plugin>
          <Name>Ec2InitializeDrives</Name>
          <State>Enabled</State>
        </Plugin>
        <Plugin>
          <Name>Ec2EventLog</Name>
          <State>Disabled</State>
        </Plugin>
        <Plugin>
          <Name>Ec2ConfigureRDP</Name>
          <State>Disabled</State>
        </Plugin>
        <Plugin>
          <Name>Ec2OutputRDPCert</Name>
          <State>Enabled</State>
        </Plugin>
        <Plugin>
          <Name>Ec2SetDriveLetter</Name>
          <State>Enabled</State>
        </Plugin>
        <Plugin>
          <Name>Ec2WindowsActivate</Name>
          <State>Enabled</State>
        </Plugin>
        <Plugin>
          <Name>Ec2DynamicBootVolumeSize</Name>
          <State>Disabled</State>
        </Plugin>
        <Plugin>
          <Name>Ec2ElasticGpuSetup</Name>
          <State>Enabled</State>
        </Plugin>
        <Plugin>
          <Name>Ec2FeatureLogging</Name>
          <State>Enabled</State>
        </Plugin>
        <Plugin>
          <Name>Ec2HandleUserData</Name>
          <State>Enabled</State>
        </Plugin>
        <Plugin>
          <Name>AWS.EC2.Windows.CloudWatch.PlugIn</Name>
          <State>Disabled</State>
        </Plugin>
      </Plugins>
      <GlobalSettings>
        <ManageShutdown>true</ManageShutdown>
        <SetDnsSuffixList>true</SetDnsSuffixList>
        <WaitForMetaDataAvailable>true</WaitForMetaDataAvailable>
        <ShouldAddRoutes>true</ShouldAddRoutes>
        <RemoveCredentialsfromSysprepOnStartup>true</RemoveCredentialsfromSysprepOnStartup>
      </GlobalSettings>
    </Ec2ConfigurationSettings>
"@
        $fileContents | Out-File -FilePath $EC2SettingsFile
    }
}
Catch
{
    $ErrorMessage = $_.Exception.Message
    $FailedItem = $_.Exception.ItemName
    echo "$ErrorMessage $FailedItem"
    return 0
}