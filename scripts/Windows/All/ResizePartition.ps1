$ErrorActionPreference = "Stop"
$VerbosePreference="Continue"

$MaxSize = (Get-PartitionSupportedSize -DriveLetter $env:TARGET_DRIVE).sizeMax
Resize-Partition -DriveLetter $env:TARGET_DRIVE -Size $MaxSize
