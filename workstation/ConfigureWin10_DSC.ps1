Configuration myChocoConfig
{
$chocoPkgs = "atom","git.install","gitextensions","curl","postman","sysinternals","easyconnect","notepadplusplus"
   Import-DscResource -Module cChoco
   Node "localhost"
   {
      LocalConfigurationManager
      {
          ConfigurationMode = "ApplyAndAutoCorrect"
          ConfigurationModeFrequencyMins = 30 #must be a multiple of the RefreshFrequency and how often configuration is checked
      }
      <#cChocoInstaller installChoco
      {
        InstallDir = "c:\choco"
      }#>
   }
   foreach($pkg in $chocoPkgs)
   {
     Node "localhost"
     {
       Name = $pkg
       Ensure = "Present"
       DependsOn = "[cChocoInstaller]installChoco"
     }
   }
}

Start-DscConfiguration -Path $config.psparentpath -Wait -Verbose -Force

# need to set WinRM service to started, with auto delayed start
# running scripts is disabled on win10, how to allow?
