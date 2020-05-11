# Accessing online media source proved inconsistent with packer - switched to this method
# which uses AWS provided Win Media sources as EBS snapshots
# See https://docs.aws.amazon.com/AWSEC2/latest/WindowsGuide/windows-optional-components.html

$ErrorActionPreference = "Stop"
$VerbosePreference = "Continue"

try {
    $currentaz = Invoke-RestMethod "http://169.254.169.254/latest/meta-data/placement/availability-zone"
    $instanceid = Invoke-RestMethod "http://169.254.169.254/latest/meta-data/instance-id"

    Write-Host('Finding Win 2012R2 Install Media EBS Snapshot')
    $snapshot = Get-EC2Snapshot -Filter @(
    @{
        name="owner-alias"
        value="amazon"
    }
    @{
        name="description"
        value="Windows 2012 R2 English Installation Media"
    })
    Write-Host('Got Snapshot ID: ' + $snapshot.SnapshotId)

    Write-Host('Creating new EBS Volume to host install media')
    $ebsvolume = New-EC2Volume -AvailabilityZone $currentaz -VolumeType gp2 -SnapshotId $snapshot.SnapshotId
    Write-Host('Created EBS Volume ID: ' + $ebsvolume.VolumeId)

    $ebsvolumestatus = Get-EC2Volume -VolumeId $ebsvolume.VolumeId
    while ($ebsvolumestatus.Status.Equals('creating')) {
        Write-Host('Waiting for volume to become available')
        Start-Sleep -Seconds 10
        Clear-Variable -Name ebsvolumestatus
        $ebsvolumestatus = Get-EC2Volume -VolumeId $ebsvolume.VolumeId
        Write-Host('Volume Status: ' + $ebsvolumestatus.Status)
    }
    if (! $ebsvolumestatus.Status.Equals('available')) {
        Write-Host('Error with EBS Volume. Final Status: ' + $ebsvolumestatus.Status)
        Exit 1
    } else {
        Write-Host('EBS Volume: ' + $ebsvolumestatus.Status)
    }

    Write-Host('Attaching media volume')
    $winvolume = Add-EC2Volume -InstanceId $instanceid -VolumeId $ebsvolume.VolumeId -Device /dev/xvdh
    Write-Host('Checking Windows Disk Manager Status')
    $winvolumestatus = Get-Disk -Number 2
    while ($winvolumestatus.OperationalStatus -ne "Online") {
        Write-Host('Waiting for new disk to come online. Current status: ' + $winvolumestatus.OperationalStatus)
        if ($winvolumestatus.OperationalStatus -eq "Offline") {
            Write-Host('Set Disk 1 Online')
            Set-Disk -Number 2 -IsOffline $False
        }
        Start-Sleep -Seconds 10
        Clear-Variable -Name winvolumestatus
        # Debug step
        Get-Disk
        $winvolumestatus = Get-Disk -Number 2
    }
    Write-Host('New Disk Online - Making Available')
    Write-Host('*** Note:')
    Write-Host('For MISNART we use Disk Number 2 (not 1) as this packer instance already has a 2nd drive attached')
    Write-Host('***')
    $winvolumedrive = Get-Partition -DiskNumber 2
    $winvolumeready = Set-Partition -DriveLetter $winvolumedrive.DriveLetter -IsActive $true -IsReadOnly $true
    Start-Sleep -Seconds 60
}
catch [Exception] {
    Write-Host ('Failed to attach Win 2012R2 Install Media from EBS Snapshot')
    echo $_.Exception|format-list -force
    Exit 1
}

try {
    Write-Host('*** Note:')
    Write-Host('For MISNART we use Disk Number 2 (not 1) as this packer instance already has a 2nd drive attached')
    Write-Host('***')
    $winvolumedrive = Get-Partition -DiskNumber 2
    Write-Host('Installing DotNet3.5 from media volume on drive: ' + $winvolumedrive.DriveLetter)
    $mediasource = $winvolumedrive.DriveLetter + ":\sources\sxs"

    Get-ChildItem -Path "$mediasource"

    Install-WindowsFeature -Name "Net-Framework-Core" -Source "$mediasource"
    
    if (Get-WindowsFeature -Name Net-Framework-Core) {
        Write-Host('DotNet 3.5 Installed Successfully')
    } else {
        Write-Host('Error - Install of DotNet 3.5 Failed')
        Exit 1
    }
}
catch [Exception] {
    Write-Host ('Failed to enable .Net3.5 Windows Feature')
    echo $_.Exception|format-list -force
    Exit 1
}

try {
    Write-Host('Set Windows Media Source Partition Offline')
    Set-Partition -DriveLetter $winvolumedrive.DriveLetter -IsActive $false
    Write-Host('Detaching EBS Volume from Host')
    $ebsvolumedetach = Dismount-EC2Volume -InstanceId $instanceid -VolumeId $ebsvolume.VolumeId -Device /dev/xvdh
    $ebsvolumedetach = Get-EC2Volume -VolumeId $ebsvolume.VolumeId
    while ($ebsvolumedetach.State.Equals('in-use') -or $ebsvolumedetach.State.Equals('detaching')) {
        Write-Host('Waiting for volume to detach')
        Start-Sleep -Seconds 10
        Clear-Variable -Name ebsvolumedetach
        $ebsvolumedetach = Get-EC2Volume -VolumeId $ebsvolume.VolumeId
    }
    if ($ebsvolumedetach.State -eq 'available') {
        Write-Host('EBS Volume Detached. Deleting.')
    } else {
        Write-Host('Error - Failed to detach volume')
        Exit 1
    }
    Remove-EC2Volume -VolumeId $ebsvolume.VolumeId -Force -PassThru
}
catch [Exception] {
    Write-Host ('Failed to remove Windows Media EBS Volume')
    echo $_.Exception|format-list -force
    Exit 1
}