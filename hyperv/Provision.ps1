#[DSCLocalConfigurationManager()]
configuration BaseConfig {
  Param (
    [Parameter(Mandatory)]
    [string]$NodeName = 'localhost',

    [Parameter(Mandatory)]
    [string]$vmName,

    [Parameter(Mandatory)] 
    [string]$IPAddress,

    [Parameter(Mandatory)]
    [string]$DefaultGateway = '192.168.1.1',

    [Parameter(Mandatory)]
    [int]$SubnetMask = 24, 

    [Parameter(Mandatory)] 
    [string]$DnsServerAddress = '192.168.1.1',

    [Parameter(Mandatory)] 
    [string]$InterfaceAlias = 'Management',

    [ValidateSet("IPv4","IPv6")] 
    [string]$AddressFamily = 'IPv4' 
    )

  Import-DscResource -ModuleName xComputerManagement
  Import-DscResource -ModuleName xNetworking

  Node $NodeName {
    
    xComputer RenameComputer
    {
        Name = $vmName
    }

    xIPAddress NewIpAddress
    {
        IPAddress = $IPAddress
        InterfaceAlias = $InterfaceAlias
        SubnetMask = $SubnetMask
    }

    xDefaultGatewayAddress SetDefaultGateway
    {
        InterfaceAlias = $InterfaceAlias
        AddressFamily = $AddressFamily
        Address = $DefaultGateway
    }

    xDnsServerAddress DnsServerAddress
    {
        Address = $DnsServerAddress
        InterfaceAlias = $InterfaceAlias
        AddressFamily = $AddressFamily
    }
  }
}

# Hyper-V target host
$vmHost = "cthulhu"

# Name of vSwitch to use on Hyper-V target host
$vSwitch = "Public_vSwitch"

# Source path for vhd
$vhdSource = "v:\Templates"

# Name of source vhd
$vhdName = "Win2012_R2-Activated.vhdx"

# Target path for vhd
$vhdTarget = "v:\VMs"
$vhdTargetSmb = "v$\VMs"

# Prompt user for VM number, this will be used for naming and ip
$vmNum = Read-Host -Prompt 'Input VM number (101-120)'

$vmName = "Win2012-VM-$vmNum"

$IPAddress = "192.168.1.$vmNum"

$mofPath = "c:\temp\dsc"

$NodeName = 'localhost'

$DefaultGateway = '192.168.1.1'

$SubnetMask = 24

$DnsServerAddress = '192.168.1.1'

$InterfaceAlias = 'Management'

$AddressFamily = 'IPv4'

BaseConfig `
    -vmName $vmName `
    -IPAddress $IPAddress `
    -OutputPath $mofPath `
    -NodeName $NodeName `
    -DefaultGateway $DefaultGateway `
    -SubnetMask 24 `
    -DnsServerAddress $DnsServerAddress `
    -InterfaceAlias $InterfaceAlias `
    -AddressFamily $AddressFamily

Rename-Item -Path "$mofPath\localhost.mof" -NewName "$vmName.mof"

New-Item -ItemType directory -Path "\\$vmHost\$vhdTargetSmb\$vmName" -Force
New-Item -ItemType directory -Path "\\$vmHost\$vhdTargetSmb\$vmName\dsc" -Force

Copy-Item -Path "$mofPath\$vmName.mof" -Destination "\\$vmHost\$vhdTargetSmb\$vmName\dsc\$vmName.mof" -Force

# make sure to name the file after the computer
$MyScriptBlock = {
    # Create folder for new VM
    New-Item -ItemType directory -Path "$Using:vhdTarget\$Using:vmName" -Force

    # Copy the base vhd
    Copy-Item -Path "$Using:vhdSource\$Using:vhdName" -Destination "$Using:vhdTarget\$Using:vmName\$Using:vmName.vhdx"

    # Mount VHD, Inject dsc file
    $MountedDisk = Mount-VHD -Path "$Using:vhdTarget\$Using:vmName\$Using:vmName.vhdx" -Passthru
    [String]$DriveLetter = ($MountedDisk | Get-Disk | Get-Partition | ? {$_.Type -eq "Basic"} | Select-Object -ExpandProperty DriveLetter) + ":"
    $DriveLetter = $DriveLetter.Replace(' ','')
    Copy-Item -Path "$Using:vhdTarget\$Using:vmName\dsc\$Using:vmName.mof" -Destination "$DriveLetter\localhost.mof" -Force
    #Copy-Item -Path "$vDiskPath\unattend.xml" -Destination "$DriveLetter\unattend.xml" -Force

    # Unmount the new VHD
    Dismount-VHD "$Using:vhdTarget\$Using:vmName\$Using:vmName.vhdx"

    New-VM -VHDPath "$Using:vhdTarget\$Using:vmName\$Using:vmName.vhdx" -Generation 2 -MemoryStartupBytes 512MB -SwitchName $Using:vSwitch -Name $Using:vmName -Path "$Using:vhdTarget\$Using:vmName"

    Set-VMProcessor -VMName $Using:vmName -Count 2

    Enable-VMIntegrationService -VMName $Using:vmName -Name 'Guest Service Interface'
}

Invoke-Command -ComputerName $vmHost -ScriptBlock $MyScriptBlock

# Start the new VM
Start-Vm -ComputerName $vmHost -Name $vmName