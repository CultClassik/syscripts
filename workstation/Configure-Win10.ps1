####################
##  Chris Diehl
##  Created 9-30-16
##  v0.2
###################

# variables set here
$pyVer = "3.5.2"

function killApps {
  #Uninstall 3D Builder:
  Get-AppxPackage *3dbuilder* | Remove-AppxPackage
  #Uninstall Alarms and Clock:
  Get-AppxPackage *windowsalarms* | Remove-AppxPackage
  #Uninstall Calculator:
  #Get-AppxPackage *windowscalculator* | Remove-AppxPackage
  #Uninstall Calendar and Mail:
  Get-AppxPackage *windowscommunicationsapps* | Remove-AppxPackage
  #Uninstall Camera:
  Get-AppxPackage *windowscamera* | Remove-AppxPackage
  #  Uninstall Get Office:
  Get-AppxPackage *officehub* | Remove-AppxPackage
  # Uninstall Get Skype:
  Get-AppxPackage *skypeapp* | Remove-AppxPackage
  #  Uninstall Get Started:
  Get-AppxPackage *getstarted* | Remove-AppxPackage
  # Uninstall Groove Music:
  Get-AppxPackage *zunemusic* | Remove-AppxPackage
  # Uninstall Maps:
  Get-AppxPackage *windowsmaps* | Remove-AppxPackage
  # Uninstall Microsoft Solitaire Collection:
  Get-AppxPackage *solitairecollection* | Remove-AppxPackage
  # Uninstall Money:
  Get-AppxPackage *bingfinance* | Remove-AppxPackage
  # Uninstall Movies & TV:
  Get-AppxPackage *zunevideo* | Remove-AppxPackage
  # Uninstall News:
  Get-AppxPackage *bingnews* | Remove-AppxPackage
  # Uninstall OneNote:
  Get-AppxPackage *onenote* | Remove-AppxPackage
  # Uninstall People:
  Get-AppxPackage *people* | Remove-AppxPackage
  # Uninstall Phone Companion:
  Get-AppxPackage *windowsphone* | Remove-AppxPackage
  # Uninstall Photos:
  Get-AppxPackage *photos* | Remove-AppxPackage
  # Uninstall Store:
  Get-AppxPackage *windowsstore* | Remove-AppxPackage
  # Uninstall Sports:
  Get-AppxPackage *bingsports* | Remove-AppxPackage
  # Uninstall Voice Recorder:
  Get-AppxPackage *soundrecorder* | Remove-AppxPackage
  # Uninstall Weather:
  Get-AppxPackage *bingweather* | Remove-AppxPackage
  #Uninstall Xbox:
  Get-AppxPackage *xboxapp* | Remove-AppxPackage
}

function doDevTools {
  ################################
  ### install modules
  ################################
  Install-Module posh-git -Force
  # Pester - unit testing for Powershell
  Install-Module -Name Pester -Confirm:$true -Force
  Install-Module -Name PSScriptAnalyzer -Confirm:$true -Force

  ################################
  ### install packages from chocolatey
  ################################
  choco install atom -y
  choco install nuget.commandline -pre
  choco install git.install -y
  choco install gitextensions -y
  choco install curl -y
  choco install packer -y
  choco install postman -y
}

function doPython {
  cd $env:TEMP
  Invoke-WebRequest -Uri "https://www.python.org/ftp/python/$pyVer/python-$pyVer.exe" -OutFile python_installer.exe
  python_installer.exe /simple InstallAllUsers=1 TargetDir=C:\Python PrependPath=1
  del python_installer.exe
}

function doSysTools {
  choco install sysinternals -y
  choco install easyconnect -y
  choco install notepadplusplus -y
  #choco install freecommander-xe -y
  #choco install speedcrunch -y
}

function doChromeCfg {
    choco install googlechrome -y
}

function doChefCfg {
  # ChefDK install
  choco install chefdk -y --force

  # ruby specific Atom stuff, only needed for Chef
  gem install kitchen-pester
  gem install rubocop

  # Create a rubocop.yml configuration file to ignore warnings for line endings. Details here https://github.com/bbatsov/rubocop/blob/master/README.md
  Set-Content -Path ~/.rubocop.yml -Value 'Metrics/LineLength:','  Enabled: false'

  # Create knife.rb config - more details here https://docs.chef.io/config_rb_knife.html
  ##atom ~/.chef/knife.rb

  # Create Berksfile config - more details here http://berkshelf.com/
  ##atom ~/.berkshelf/config.json

  # Verify you can communicate with the chef server
  ##knife user list
}

function doDockerCfg {
    choco install docker -y
}

function doAzureCfg {
    echo "Installing AzureRM stuff for Powershell, this action will probably take a while.."
    Install-Module AzureRM -Force
}

function doAwsCfg {
    echo "Installing AWS stuff for Powershell, this action will probably take a while.."
    choco install awstools.powershell
}

function doVirtCfg ($myVirt) {
  switch ($myVirt) {
    "virtualbox" {
      choco install virtualbox -y
    }
    "hyperv" {
      Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All
    }
  }
}

function doVagrantCfg($myVirt = 'vsphere') {
  # install vagrant
  choco install vagrant -y
  #$env:Path += ";C:\HashiCorp\Vagrant\bin\"

  # Install vagrant plugins
  #vagrant plugin install 'vagrant-rbvmomi'
  #vagrant plugin install 'nokogiri'
  vagrant plugin install 'vagrant-berkshelf'
  vagrant plugin install 'vagrant-dsc'
  vagrant plugin install 'vagrant-omnibus'
  vagrant plugin install 'vagrant-reload'
  vagrant plugin install 'vagrant-winrm'
  vagrant plugin install 'winrm-fs'

  # Install vagrant boxes
  # vagrant box add ubuntu/trusty64
  # vagrant box add kensykora/windows_2012_r2_standard

  # install xtra plugins for vagrant if virtualbox was installed
  if ($myVirt -eq "virtualbox") {
    vagrant plugin install 'vagrant-vbguest'
    vagrant plugin install 'vagrant-vbox-snapshot'
  }

  ################################
  ### optional vagrant providers install
  ################################
  if ($doVagrant -eq 6) {
    vagrant plugin install 'vagrant-aws'
    vagrant plugin install 'vagrant-azure'
    vagrant plugin install 'vagrant-vsphere'
    #vagrant plugin install 'vagrant-vcenter'
    #vagrant plugin install 'vagrant-vcloud'
  }

  # Set the default hypervisor provider for Vagrant
  [Environment]::SetEnvironmentVariable("VAGRANT_DEFAULT_PROVIDER", $myVirt, "Machine")
}

function updatePath($pathItem) {
    $oldPath = (Get-ItemProperty -Path "Registry::HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment" -Name PATH).Path
    $newPath = $oldPath + ";$pathItem"
    Set-ItemProperty -Path "Registry::HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment" -Name PATH -Value $newPath
    return $newPath
    #$($Env:PATH).Split(';') | %{ $str += "$($_.Trim('"'));" }; $Env:PATH=$str
}

################################################################################################################################################
######################################################################## BEGIN #################################################################
################################################################################################################################################

# load external functions
. "$($MyInvocation.MyCommand.path | split-path)\Win10-Optimize.ps1"
#. "$($MyInvocation.MyCommand.path | split-path)\Win10-AppInstall.ps1"

# get os version
$myos = (Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion" -Name ProductName).ProductName

function getSpecs {
  # chefk for dot net 4.5 (full, not client)
  $dotNet45 = (Get-ItemProperty -Path 'HKLM:\Software\Microsoft\NET Framework Setup\NDP\v4\Full' -ErrorAction SilentlyContinue).Version -like '4.5*'

  $message = "OS: $myos `r`n MS .NET 4.5 Installed: $dotNet45 `r`n `r`n" +
      "This script should be run as Administrator.  If you get prompted to allow the install of nuget-anycpu.exe say yes. `r`n `r`n" +
      "If you have Windows Firewall enabled, you will also need to say Yes if asked to allow Ruby. `r`n `r`n" +
      "Click OK to start or Cancel."

  return $message
}

# tell user we're about to start, allow them to proceed or cancel
$msg = getSpecs
$wshell = New-Object -ComObject Wscript.Shell
$doInstall = $wshell.Popup($msg,0,"Info",1)
If ($doInstall -eq 2) {
    break
}

################################
### get option input from user
################################
$doRmPkg = $wshell.Popup("Try to remove un-needed packages from Windows?  `r`n `r`n" +
  "***** `r`nYou might not want to do this on a phyiscal PC, check the file Win10-RemovePackages.ps1 to see what it does first!  `r`n ***** `r`n `r`n" +
  "You may see some errors if we try this, just ignore them."
  ,0,"",4)

<#
$doSvcs = $wshell.Popup("Disable commonly unused Windows services and disable the firewall, aka optimize Windows?",0,"",4)
if ($doSvcs -eq 6) {
  disableSvcs
}
optimizeWin
#>
$doDevTools = $wshell.Popup("Install the dev tools?",0,"",4)

$doPython = $wshell.Popup("Install the Python $pyVer? (Will be installed regardless if you install AWS EB CLI)",0,"",4)

$doAwsEbCli = $wshell.Popup("Install the AWS EB CLI?",0,"",4)

$doSysApps = $wshell.Popup("Install the system tools?",0,"",4)

$doChef = $wshell.Popup("Install ChefDK?",0,"",4)

$doDocker = $wshell.Popup("Install Docker Tools?",0,"",4)

$doAzure = $wshell.Popup("Install Azure PS tools?",0,"",4)

$doAws = $wshell.Popup("Install AWS PS tools?",0,"",4)

If ($myos -eq "Windows 10 Pro") {
  $doVirt = $wshell.Popup("Install Hyper-V?",0,"",4)
  If ($doVirt -eq 6) {
    $myVirt = "hyperv"
  }
}

If ($doVirt -eq 7) {
  $doVirt = $wshell.Popup("Install VirtualBox?",0,"",4)
    if ($doVirt -eq 6) {
      $myVirt = "virtualbox"
    }
}

$doVagrant = $wshell.Popup("Install Vagrant?",0,"",4)

#$doChrome = $wshell.Popup("Install Chrome?",0,"",4)

# Configure PowerShell Execution Policy
#Set-ExecutionPolicy RemoteSigned

<#
If ($doSvcs -eq 6) {
  & "$($MyInvocation.MyCommand.path | split-path)\Debloat-Windows10.ps1"
}
#>

###########################
### Windows tweaks
###########################
$key = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'
Set-ItemProperty $key -Name SuperHidden -Value 00000001
Set-ItemProperty $key -Name ShowSuperHidden -Value 00000001
Set-ItemProperty $key -Name HideFileExt -Value 00000000
Set-ItemProperty $key -Name Hidden -Value 00000001

################################################################################################################################

################################
### Install Chocolatey
################################
iex ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1'))
choco install wget -y

###########################
### Install optional items
###########################
if ($doRmPkg -eq 6) {
  #. "$($MyInvocation.MyCommand.path | split-path)\Win10-RemovePackages.ps1"
  killApps
}

if ($doDevTools -eq 6) {
  doDevTools
  Start-Process cmd.exe -FilePath .\Win10-AtomPkgs.cmd
}

if ($doPython -eq 6) {
  doPython
}

if ($doAwsEbCli -eq 6) {
  doPython
  pip install awsebcli
}

if ($doSysApps -eq 6) {
  doSysTools
}

if ($doChef -eq 6) {
  $item="C:\opscode\chefdk\embedded\bin"
  $env:Path = updatePath $item
  doChefCfg
}

if ($doDocker -eq 6) {
  doDockerCfg
}

if ($doAzure -eq 6) {
  doAzureCfg
}

if ($doAws -eq 6) {
  doAwsCfg
}

if ($doVirt -eq 6) {
  doVirtCfg $myVirt
}

if ($doVagrant -eq 6) {
  $item="C:\HashiCorp\Vagrant\bin"
  $env:Path = updatePath $item
  doVagrantCfg $myVirt
}

###########################
### Powershell Profile
###########################
$profExists = Test-Path $profile
if ($profExists -eq 0) {
  $newProf = New-Item -path $profile -type file -Force
}
'set-location c:\code' | Out-File -File $newProf -Append -Force
'$shell.BackgroundColor = “Gray”'  | Out-File -File $newProf -Append -Force
'$shell.ForegroundColor = “Black”' | Out-File -File $newProf -Append -Force
'Clear-Host' | Out-File -File $newProf -Append -Force

#### move ps profile to synced folder like dropbox or onedrive
#cmd /c mklink $PROFILE D:\DataHodge\Dropbox\PSProfile\Microsoft.PowerShell_profile.ps1

# Load the profile into the current session
#. $PROFILE


####
#### Create links, shortcuts, etc
####

# enable ps remoting?
