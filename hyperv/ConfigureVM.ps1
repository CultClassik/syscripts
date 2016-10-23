function optimizePageFile {
  $System = GWMI Win32_ComputerSystem -EnableAllPrivileges
  $System.AutomaticManagedPagefile = $False
  $System.Put()

  $CurrentPageFile = gwmi -query "select * from Win32_PageFileSetting where name='c:\\pagefile.sys'"
  $CurrentPageFile.InitialSize = 512
  $CurrentPageFile.MaximumSize = 512
  $CurrentPageFile.Put()
}

Dism.exe /online /Cleanup-Image /StartComponentCleanup /ResetBase

Add-WindowsFeature -Name Desktop-Experience
#reboot needed after installing Desktop-experience?
# this is interactive:
C:\Windows\System32\cleanmgr.exe /d c:

# zero out unused space to mark as fully empty
wget http://download.sysinternals.com/files/SDelete.zip -OutFile sdelete.zip
[System.Reflection.Assembly]::LoadWithPartialName("System.IO.Compression.FileSystem")
[System.IO.Compression.ZipFile]::ExtractToDirectory("sdelete.zip", ".")
./sdelete.exe -z c:

# run from vm host or other
Optimize-VHD -Path C:\path\to\my.vhd -Mode Full

Enable-PSRemoting -Force

# trust all hosts, good for lab, bad for production
Set-Item wsman:\localhost\client\trustedhosts *

Restart-Service WinRM
