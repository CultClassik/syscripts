break
# get os version
$myos = (get-itemproperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion" -Name ProductName).ProductName
# chefk for dot net 4.5 (full, not client)
$dotNet45 = (Get-ItemProperty -Path 'HKLM:\Software\Microsoft\NET Framework Setup\NDP\v4\Full' -ErrorAction SilentlyContinue).Version -like '4.5*'
echo "OS: $myos"
echo "MS .NET 4.5 Installed: $dotNet45"
echo "If you get prompted to allow the install of nuget-anycpu.exe say yes."

$doChef = Read-Host -Prompt "Install ChefDK? (y/n)"
$doDocker = Read-Host -Prompt "Install Docker tools? (y/n)"
$doAzure = Read-Host -Prompt "Install Azure tools? (y/n)"
$doVagrant = Read-Host -Prompt "Install Vagrant? (y/n)"

# Configure PowerShell Execution Policy
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Force

# Install Chocolatey
iex ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1'))

# install packages
choco install sysinternals -y
choco install nuget.commandline -pre
choco install git.install -y
choco install curl -y
choco install clover -y
choco install easyconnect -y
choco install notepadplusplus -y
choco install atom -y

# install modules
Install-Module posh-git -Force
Install-Module -Name Pester -Confirm:$true -Force
Install-Module -Name PSScriptAnalyzer -Confirm:$true -Force

# optional chef install
if ($doChef -eq "y") {
    choco install chefdk -y --force
    Add-PathVariable -Path 'C:/opscode/chefdk/embedded/bin'
    # Create knife.rb config - more details here https://docs.chef.io/config_rb_knife.html
    atom ~/.chef/knife.rb

    # Create Berksfile config - more details here http://berkshelf.com/
    atom ~/.berkshelf/config.json

    # Verify you can communicate with the chef server
    knife user list
    }

# optional docker install
if ($doDocker -eq "y") {
    choco install docker -y
    }

# optional azure specific
If ($doAzure -eq "y") {
    echo "Ok, this action will probably take a while.."
    Install-Module AzureRM -Force
    }

# install hyper-v if supported, otherwise install virtualbox
#choco install virtualbox -y
#Install-WindowsFeature Name Hyper-V -ComputerName localhost -IncludeManagementTools -Restart

# optional vagrant install
# set vagrant default provider here - vbox, hyperv, azure, etc
If ($doVagrant -eq "y") {
    choco install vagrant -y
    vagrant plugin install vagrant-winrm
    # Install vagrant plugins
    vagrant plugin install 'vagrant-berkshelf'
    vagrant plugin install 'vagrant-dsc'
    vagrant plugin install 'vagrant-omnibus'
    vagrant plugin install 'vagrant-reload'
    vagrant plugin install 'vagrant-vbguest'
    vagrant plugin install 'vagrant-vbox-snapshot'
    vagrant plugin install 'vagrant-winrm'
    vagrant plugin install 'winrm-fs'

    # Install vagrant boxes
    # vagrant box add ubuntu/trusty64
    # vagrant box add kensykora/windows_2012_r2_standard

    # Install the test-kitchen plugins
    gem install kitchen-pester
    }

# Optional - free git GUI
#choco install sourcetree -y
# OR you could try
#choco install gitextensions -y

#### move ps profile to synced folder
# Create a symlink to the profile in your shared drive
cmd /c mklink $PROFILE D:\DataHodge\Dropbox\PSProfile\Microsoft.PowerShell_profile.ps1

# Load the profile into the current session
. $PROFILE

#########################################
### Install Atom and Packages
#########################################

# Linter to validate the code as you are typing
apm install linter

# Install rubocop gem
gem install rubocop

# Linter for ruby
apm install linter-rubocop

# Rubocop auto corrector
apm install rubocop-auto-correct

# Create a rubocop.yml configuration file to ignore warnings for line endings. Details here https://github.com/bbatsov/rubocop/blob/master/README.md
Set-Content -Path ~/.rubocop.yml -Value 'Metrics/LineLength:','  Enabled: false'

# Useful for removing Windows line endings
apm install line-ending-converter

# Gives a view of your entire document when it is open in atom
apm install minimap

# monokai theme for atom
apm install monokai





####
#### Create links, shortcuts, etc
####

# enable ps remoting?