function killApps {
  Get-AppxPackage -name "Microsoft.ZuneMusic" | Remove-AppxPackage
  Get-AppxPackage -name "Microsoft.Music.Preview" | Remove-AppxPackage
  Get-AppxPackage -name "Microsoft.Windows.Cortana" | Remove-AppxPackage
  Get-AppxPackage -name "Microsoft.XboxGameCallableUI" | Remove-AppxPackage
  Get-AppxPackage -name "Microsoft.XboxIdentityProvider" | Remove-AppxPackage
  Get-AppxPackage -name "Microsoft.People" | Remove-AppxPackage
  Get-AppxPackage -name "Microsoft.3DBuilder" | Remove-AppxPackage
  Get-AppxPackage -name "Microsoft.WindowsCalculator" | Remove-AppxPackage
  Get-AppxPackage -name "Microsoft.XboxApp" | Remove-AppxPackage
  Get-AppxPackage -name "Microsoft.WindowsCamera" | Remove-AppxPackage
  Get-AppxPackage -name "Microsoft.Getstarted" | Remove-AppxPackage
  Get-AppxPackage -name "Microsoft.Office.OneNote" | Remove-AppxPackage
  Get-AppxPackage -name "Microsoft.WindowsMaps" | Remove-AppxPackage
  Get-AppxPackage -name "Microsoft.MicrosoftSolitaireCollection" | Remove-AppxPackage
  Get-AppxPackage -name "Microsoft.MicrosoftOfficeHub" | Remove-AppxPackage
  Get-AppxPackage -name "Microsoft.BingWeather" | Remove-AppxPackage
  Get-AppxPackage -name "Microsoft.ZuneVideo" | Remove-AppxPackage
  Get-AppxPackage -name "Microsoft.SkypeApp" | Remove-AppxPackage
  Get-AppxPackage -name "*Bing*" | % { Remove-AppxPackage $_ }
  #Get-AppxPackage -AllUsers | Remove-AppxPackage
  #Get-AppXProvisionedPackage -online | Remove-AppxProvisionedPackage –online
  # Get-AppxPackage -name "Microsoft.Windows.CloudExperienceHost" | Remove-AppxPackage
  # Get-AppxPackage -name "Microsoft.BioEnrollment" | Remove-AppxPackage
  # Get-AppxPackage -name "Microsoft.WindowsStore" | Remove-AppxPackage
  # Get-AppxPackage -name "Microsoft.Windows.Photos" | Remove-AppxPackage
  # Get-AppxPackage -name "Microsoft.WindowsPhone" | Remove-AppxPackage
}
