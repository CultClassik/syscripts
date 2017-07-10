#
#  Chris Diehl <chris@diehlabs.com>
#
#  Manage Hyper-V guests
#
param (
    [string]$vmHost = "localhost",
    [string]$action = "create"
 )

Import-Module Hyper-V

$vmHost = "dagon"
Get-VM -ComputerName $vmHost -Name Win2016
Get-VMStoragePath - -ComputerName $vmHost -VMName Win2016

 if ($action -eq "rm") {

 }

# https://gist.githubusercontent.com/devblackops/989bf64ad8d24fcafac1/raw/a1277f4b30c7ac32d908121ef3ce6b7f589dd000/chefquery.ps1
. ./chefquery.ps1

# Define available VM names with their generation and VHD name
$vmTemplates = @{
    "CentOS_7" = @{
        "vhd" = "CenOS_7.vhdx";
        "vmGen" = 1;
        };
    "Ubuntu_14.04" = @{
        "vhd" = "Ubuntu_14.04.vhdx";
        "vmGen" = 1;
        };
    "Win2012_R2" = @{
        "vhd" = "Windows_2012_R2.vhdx";
        "vmGen" = 2;
        };
    "Win10" = @{
        "vhd" = "Windows_10.vhdx";
        "vmGen" = 1;
        };
    }

$data = @{
    "user" = "chris";
    "pass"="";
    "vmHost" = $vmHost;
    "vDiskPath" = "c:\VM_Templates";
    "vmTemplates" = $vmTemplates;
    "vmHostPath" = "C:\VMs";
    "chefCert" = "C:\Users\chris\Documents\projects\chef-repo\.chef\chris.pem";
    }

$select = @{
    "vmTemplate" = "";
    "vSwitch" = "";
    "vmNum" = "";
    "vmName" = "";
    "vmPath" = "";
    }


# Prompt for password and add it to the data hash table
$password = Read-host "Password for the Hyper-V Host:" -AsSecureString
$data.pass = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($password))

#
# Display the list of templates along with the hash table index number
#
#$vmTemplates.PSObject.Properties['Count'].Value
foreach ($t in $vmTemplates.GetEnumerator()) {
    $num = $($vmTemplates.keys).indexOf($t.name)
    Write-Host "$num : $($t.name)"
}
# Prompt for the VM template to use and store the key name from $vmTemplates in the $select hash table
$templateNumber = Read-host "Enter the number of the template to provision"

# Ugly but might be the only way to address a hash table item via index number in PowerShell?
foreach ($t in $vmTemplates.GetEnumerator()) {
    $num = $($vmTemplates.keys).indexOf($t.name)
    if ($num -eq $templateNumber) {
        $select.vmTemplate = $t.name
        }
}
Write-Host $select.vmTemplate "selected."

# this really isn't needed now that the script has changed so much
# Get-VM -ComputerName $data.vmHost

#
# Enumerate the vswitches on the hv host and ask the user to select one
#

# need to get this working, use static value for now
#$vSwitches = Get-VMSwitch -ComputerName $data.vmHost | select name | Format-Table -HideTableHeaders
#echo $vSwitches
$select.vSwitch = "Public_vSwitch_VLAN-20"

#
# Set the name / number for the new VM
#

#prompt user for VM number, this will be used for naming and ip
# set $select.vmNum
$vmNum = Read-Host -Prompt 'Input VM number'

# Set the name for the new VM
$select.vmName = $select.vmTemplate + "-$vmNum"
#echo $select

#
# Copy VHD and create VM on the Hyper-V host
#

$sess = New-PSSession -ComputerName $data.vmHost

# Create new VM folder
Write-Host "Creating destination folder.."
Invoke-Command -Session $sess -ArgumentList $data.vmHostPath, $select.vmName `
-ScriptBlock {
    param($vmHostPath, $vmName)
    New-Item -ItemType directory -Path "$vmHostPath\$vmName" -Force
    }

# Copy the template VHD to the newly created folder
Write-Host "Copying VHD, please wait..."

$select.vmPath = ($data.vmHostPath+"\"+$select.vmName)

Invoke-Command -Session $sess -ArgumentList ($data.vDiskPath+"\"+$vmTemplates[$select.vmTemplate].vhd), $select.vmPath `
-ScriptBlock {
    param($src, $dst)
    Copy-Item -Path $src -Destination $dst
    }

Write-Host "Creating new VM..."
# If selected vm is windows, set ram to 1024mb otherwise set 512mb
if ($select.vmTemplate.Contains("Win")) { $vRam = 1024MB } else { $vRam = 512MB }

New-VM -ComputerName $data.vmHost `
    -Name $select.vmName `
    -Generation $vmTemplates[$select.vmTemplate].vmGen `
    -MemoryStartupBytes $vRam `
    -Path $select.vmPath `
    -VHDPath ($select.vmPath+"\"+$vmTemplates[$select.vmTemplate].vhd) `
    -SwitchName $select.vSwitch

Set-VMProcessor -ComputerName $data.vmHost -VMName $select.vmName -Count 2

Enable-VMIntegrationService -ComputerName $data.vmHost -VMName $select.vmName -Name 'Guest Service Interface'

Start-Vm -ComputerName $data.vmHost -Name $select.vmName

Write-Host "Verify new VM:"
Get-VM -ComputerName $data.vmHost -Name $select.vmName

# may need to add a sleepy loop here
Write-Host "IP Address for new VM:"
Get-VM -ComputerName $data.vmHost -vm $select.vmName | Select -ExpandProperty NetworkAdapters | Select VMName, IPAddresses, Status


#Write-Host "Enter credentials for Chef Server"
#Get-PfxCertificate -FilePath $data.chefCert
#[Net.ServicePointManager]::ServerCertificateValidationCallback = { $true }
#Invoke-RestMethod -Uri https://chef.diehlabs.lan/organizations/diehlabs/nodes -Credential chris
