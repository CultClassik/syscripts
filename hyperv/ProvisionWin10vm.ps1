# Chris Diehl
# Create a Windows 2012 Server VM from existing vhd file

#name of vm host, display existing vms before choosing a number
$vmHost = "cthulhu"
Get-VM -ComputerName $vmHost

# change this later to prompt for a name, or query host for switches, if only one use that one
$vSwitch = "Public_vSwitch"

#prompt user for VM number, this will be used for naming and ip
$vmNum = Read-Host -Prompt 'Input VM number (100-120)'
$vmName = "WinServ2012-$vmNum"

# path for vhd to use with new vm
$vDiskPath = "\\cthulhu\v$\Templates\Windows2012_masterBase\Virtual Hard Disks"
$vDiskFile = "Windows_2012_Server.vhdx"

#path on vm host to store new vm
$vmHostPath = "\\$vmHost\v$\VMs\$vmName"

# create folders
echo Creating destination folder..
New-Item -ItemType directory -Path "$vmHostPath\$vmName" -Force

echo Copying VHD, please wait...
Copy-Item -Path $vDiskPath\$vDiskFile -Destination $vmHostPath

New-VM -ComputerName $vmHost -VHDPath $vmHostPath\$vDiskFile -Generation 2 -MemoryStartupBytes 512MB -SwitchName $vSwitch -Name $vmName -Path "v:\VMs\$vmName"

Set-VMProcessor -ComputerName $vmHost -VMName $vmName -Count 2

Enable-VMIntegrationService -ComputerName $vmHost -VMName $vmName -Name 'Guest Service Interface'

# Start the new VM
Start-Vm -ComputerName $vmHost -Name $vmName