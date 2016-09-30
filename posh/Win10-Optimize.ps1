function disableSvcs {
  # disable junky services
  Set-Service -Name "icssvc" -StartupType disabled #Windows Mobile Hotspot Service
  Set-Service -Name "SCPolicySvc" -StartupType disabled # Smart Card Removal Policy
  Set-Service -Name "RetailDemo" -StartupType disabled # Retail Demo Service
  Set-Service -Name "XblAuthManager" -StartupType disabled # Xbox Live Auth Manager
  Set-Service -Name "XblGameSave" -StartupType disabled # Xbox Live Game Save
  Set-Service -Name "XboxNetApiSvc" -StartupType disabled #	XboxNetApiSvc
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
