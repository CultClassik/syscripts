####################
##  Chris Diehl
##  Created 9-30-16
##  v0.1
###################
# load some functions
$optimize = "$($MyInvocation.MyCommand.path | split-path)\Win10-Optimize.ps1"
. $optimize

# get os version
$myos = (get-itemproperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion" -Name ProductName).ProductName
# chefk for dot net 4.5 (full, not client)
$dotNet45 = (Get-ItemProperty -Path 'HKLM:\Software\Microsoft\NET Framework Setup\NDP\v4\Full' -ErrorAction SilentlyContinue).Version -like '4.5*'

$message = "OS: $myos `r`n MS .NET 4.5 Installed: $dotNet45 `r`n `r`n" +
    "This script should be run as Administrator.  If you get prompted to allow the install of nuget-anycpu.exe say yes. `r`n `r`n" +
    "Click OK to continue or Cancel."

$wshell = New-Object -ComObject Wscript.Shell
$doInstall = $wshell.Popup($message,0,"Info",1)
If ($doInstall -eq 2) {
    break
}

################################
### get option input from user
################################
$doSvcs = $wshell.Popup("Disable commonly unused Windows services and disable the firewall?",0,"",4)
if ($doSvcs -eq 6) {
  disableSvcs
}
optimizeWin

$doBasics = $wshell.Popup("Install the basics?  Select yes if you haven't run this before.",0,"",4)

$doChef = $wshell.Popup("Install ChefDK?",0,"",4)

$doDocker = $wshell.Popup("Install Docker Tools?",0,"",4)

$doAzure = $wshell.Popup("Install Azure PS tools?",0,"",4)

if ($myos -eq "Windows 10 Pro") {
  $doVirt = $wshell.Popup("Install Hyper-V?",0,"",4)
  $myVirt = "hyperv"
}

if ($doVirt -eq 7) {
  $doVirt = $wshell.Popup("Install VirtualBox?",0,"",4)
  $myVirt = "virtualbox"
}

$doVagrant = $wshell.Popup("Install Vagrant?",0,"",4)

$doChrome = $wshell.Popup("Install Chrome?",0,"",4)

# Configure PowerShell Execution Policy
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Force

If ($doBasics -eq 6) {
  ################################
  ### install modules
  ################################
  Install-Module posh-git -Force -IncludeDependencies
  # Pester - unit testing for Powershell
  Install-Module -Name Pester -Confirm:$true -Force
  Install-Module -Name PSScriptAnalyzer -Confirm:$true -Force

  ################################
  ### Install Chocolatey & Git
  ################################
  iex ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1'))

  ################################
  ### install chocolatey packages
  ################################
  choco install nuget.commandline -pre
  choco install git.install -y
  #choco install poshgit
  choco install sysinternals -y
  choco install curl -y
  choco install atom -y
  # atom doesn't always seem to update the path, so do it here just in case
  $env:Path += ";$env:USERPROFILE\AppData\Local\atom\bin"
  #choco install clover -y # unable to install, not really needed may remove later
  choco install easyconnect -y
  choco install notepadplusplus -y
  choco install packer -y
  choco install postman -y
  choco install gitextensions -y

  ################################
  ### Atom standard packages
  ################################
  apm install linter
  apm install line-ending-converter
  apm install minimap
  apm install monokai
}

################################
### optional chef install
################################
if ($doChef -eq 6) {
# ChefDK install
  choco install chefdk -y --force
  Add-PathVariable -Path 'C:/opscode/chefdk/embedded/bin'

  # ruby specific Atom stuff, only needed for Chef
  gem install rubocop
  apm install linter-rubocop
  apm install rubocop-auto-correct
  # Create a rubocop.yml configuration file to ignore warnings for line endings. Details here https://github.com/bbatsov/rubocop/blob/master/README.md
  Set-Content -Path ~/.rubocop.yml -Value 'Metrics/LineLength:','  Enabled: false'

  # Create knife.rb config - more details here https://docs.chef.io/config_rb_knife.html
  atom ~/.chef/knife.rb

  # Create Berksfile config - more details here http://berkshelf.com/
  atom ~/.berkshelf/config.json

  # Verify you can communicate with the chef server
  knife user list
}

################################
### optional docker install
################################
if ($doDocker -eq 6) {
    choco install docker -y
}

################################
### optional azure specific
################################
If ($doAzure -eq 6) {
    echo "Installing AzureRM stuff for Powershell, this action will probably take a while.."
    Install-Module AzureRM -Force
}

################################
### optional hypervisor install
################################
if ($doVirt -eq 6) {
  switch ($myVirt) {
    "virtualbox" {
      choco install virtualbox -y
    }
    "hyperv" {
      Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All
    }
  }
}

################################
### optional vagrant install
################################
# set vagrant default provider here - vbox, hyperv, azure, etc
If ($doVagrant -eq 6) {
  # install vagrant
  choco install vagrant -y
  # Install vagrant plugins
  vagrant plugin install 'vagrant-berkshelf'
  vagrant plugin install 'vagrant-dsc'
  vagrant plugin install 'vagrant-omnibus'
  vagrant plugin install 'vagrant-reload'

  vagrant plugin install 'vagrant-winrm'
  vagrant plugin install 'winrm-fs'

  # Install vagrant boxes
  # vagrant box add ubuntu/trusty64
  # vagrant box add kensykora/windows_2012_r2_standard

  # Install the test-kitchen plugins
  gem install kitchen-pester

  # install xtra plugins for vagrant if virtualbox was installed
  if ($myVirt -eq "virtualbox") {
    vagrant plugin install 'vagrant-vbguest'
    vagrant plugin install 'vagrant-vbox-snapshot'
  }

  # Set the default hypervisor provider for Vagrant
  If ($doVirt -eq 7) {
    $myVirt = "vsphere"
  }
  [Environment]::SetEnvironmentVariable("VAGRANT_DEFAULT_PROVIDER", $myVirt, "Machine")
}

################################
### optional vagrant providers install
################################
if ($doVagrant -eq 6) {
  vagrant plugin install 'vagrant-aws'
  vagrant plugin install 'vagrant-azure'
  vagrant plugin install 'vagrant-vsphere'
  vagrant plugin install 'vagrant-vcenter'
  vagrant plugin install 'vagrant-vcloud'
}

################################
### optional chrome install
################################
if ($doChrome -eq 6) {
    choco install googlechrome
}

#### move ps profile to synced folder like dropbox or onedrive
#cmd /c mklink $PROFILE D:\DataHodge\Dropbox\PSProfile\Microsoft.PowerShell_profile.ps1

# Load the profile into the current session
#. $PROFILE


####
#### Create links, shortcuts, etc
####

# enable ps remoting?
