#
# Windows PowerShell script for AD DS Deployment
#

$domain = "diehlabs.tech"
$netbios = $domain.Split(".")[0].ToUpper()

Import-Module ADDSDeployment
Install-ADDSForest `
-CreateDnsDelegation:$false `
-DatabasePath "C:\Windows\NTDS" `
-DomainMode "Win2012R2" `
-DomainName $domain `
-DomainNetbiosName $netbios `
-ForestMode "Win2012R2" `
-InstallDns:$true `
-LogPath "C:\Windows\NTDS" `
-NoRebootOnCompletion:$false `
-SysvolPath "C:\Windows\SYSVOL" `
-Force:$true
