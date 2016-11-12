#[DSCLocalConfigurationManager()]
configuration BaseConfig {
  Param (
    [Parameter(Mandatory)]
    [string]$NodeName = 'localhost',

    [Parameter(Mandatory)]
    [string]$ComputerName,

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
        Name = $ComputerName
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

Import-Module Hyper-V

# Prompt user for VM number, this will be used for naming and ip
$vmNum = Read-Host -Prompt 'Input VM number (101-120)'

$ComputerName = "Win2012-VM-$vmNum"

$IPAddress = "192.168.1.$vmNum"

$mofPath = "c:\temp\dsc\$ComputerName.mof"

$NodeName = 'localhost'

$DefaultGateway = '192.168.1.1'

$SubnetMask = 24

$DnsServerAddress = '192.168.1.1'

$InterfaceAlias = 'Management'

$AddressFamily = 'IPv4'

# Hyper-V target host
$vmHost = "cthulhu"

# Name of vSwitch to use on Hyper-V target host
$vSwitch = "Public_vSwitch"

# Source path for vhd
$vhdSource = "\\$vmHost\v$\Templates"

# Name of source vhd
$vhdName = "Win2012_R2-Activated.vhdx"

# Target path for vhd
$vhdTarget = "\\$vmHost\v$\VMs\$ComputerName"

BaseConfig `
    -ComputerName $ComputerName `
    -IPAddress $IPAddress `
    -OutputPath $mofPath `
    -NodeName $NodeName `
    -DefaultGateway $DefaultGateway `
    -SubnetMask 24 `
    -DnsServerAddress $DnsServerAddress `
    -InterfaceAlias $InterfaceAlias `
    -AddressFamily $AddressFamily

# make sure to name the file after the computer


# Create folder for new VM
New-Item -ItemType directory -Path "$vhdTarget\$ComputerName" -Force

# Copy the base vhd
Copy-Item -Path $vhdSource\$vhdName -Destination $vhdTarget

# Copy the mof file
#Copy-Item -Path $mofPath -Destination $vhdTarget

New-VM -ComputerName $vmHost -VHDPath $vhdTarget\$vhdName -Generation 2 -MemoryStartupBytes 512MB -SwitchName $vSwitch -Name $ComputerName -Path "$vhdTarget\$ComputerName"

Set-VMProcessor -ComputerName $vmHost -VMName $ComputerName -Count 2

Enable-VMIntegrationService -ComputerName $vmHost -VMName $ComputerName -Name 'Guest Service Interface'

<#
# set up data to pass to the remote session
$ScriptBlockContent = {
  param ($vhdTarget)
  Write-Host $vhdtarget
  param ($vhdName)
  Write-Host $vhdName
  param ($mofFile)
  Write-Host $mofFile
   }

# persistent connection to allow the vm host to do the work faster
Enter-PSSession $vmHost
#>
# Inject dsc file
$MountedDisk = Mount-VHD -Path $vhdTarget\$vhdName -Passthru
[String]$DriveLetter = ($MountedDisk | Get-Disk | Get-Partition | ? {$_.Type -eq "Basic"} | Select-Object -ExpandProperty DriveLetter) + ":"
$DriveLetter = $DriveLetter.Replace(' ','')
#Get-PSDrive
Copy-Item -Path $mofPath -Destination "$DriveLetter\Windows\System32\Configuration\pending.mof" -Force

# Unmount the new VHD
Dismount-VHD $vhdTarget\$vhdName



# Start the new VM
Start-Vm -ComputerName $vmHost -Name $ComputerName

#>