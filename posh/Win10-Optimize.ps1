function disableSvcs {
  # disable junky services
  Set-Service -Name "icssvc" -StartupType disabled #Windows Mobile Hotspot Service
  Set-Service -Name "SCPolicySvc" -StartupType disabled # Smart Card Removal Policy
  Set-Service -Name "RetailDemo" -StartupType disabled # Retail Demo Service
  Set-Service -Name "XblAuthManager" -StartupType disabled # Xbox Live Auth Manager
  Set-Service -Name "XblGameSave" -StartupType disabled # Xbox Live Game Save
  Set-Service -Name "XboxNetApiSvc" -StartupType disabled #	XboxNetApiSvc
  Set-Service -Name "wuauserv" -StartupType disabled #	Windows Updates
  Set-Service -Name "WinDefend" -StartupType disabled #	Windows Defender
  Set-Service -Name "WdNisSvc" -StartupType disabled #	Windows Defender Network Inspection
}

function optimizeWin {
  # limit event logs to 1028k, overflow action is overwrite
  $logs = Get-EventLog -LogName * | foreach{$_.Log.ToString()}
  $limitParam = @{
      logname = ""
      Maximumsize = 1024KB
      OverflowAction = "OverwriteAsNeeded"
      }
  foreach($log in $logs) {
      $limitParam.logname = $log
      Limit-EventLog @limitParam | Where {$_.Log -eq $limitparam.logname}
      Clear-EventLog -LogName $log
      }
}

function disableWau {
  # disable windows updates
  #New-Item HKLM:\SOFTWARE\Policies\Microsoft\Windows -Name WindowsUpdate
  #New-Item HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate -Name AU
  Set-ItemProperty HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU -Name NoAutoUpdate -Value 1
}

function tweakExp {
  $key = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'
  Set-ItemProperty $key -Name SuperHidden -Value 00000001
  Set-ItemProperty $key -Name ShowSuperHidden -Value 00000001
  Set-ItemProperty $key -Name HideFileExt -Value 00000000
  Set-ItemProperty $key -Name Hidden -Value 00000001
}
