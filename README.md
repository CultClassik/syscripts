# syscripts

This repository contains a collection of scripts I used to automate the setup of a new system.

I  used Matthew Hodgkins's plog post as inspiration (or copy/paste fodder, depending..)

https://hodgkins.io/setup-windows-10-for-chef-and-powershell-dsc-development


Pretty simple Powershell script, this will grow over time. Note that I use this on Windows 10 Pro, it probably will throw a big malf if you use it on anything else.  You have been warned ;)

To run Win10-Dev-Env.ps1, open Powershell as Administrator and use this command line:

`powershell -ExecutionPolicy ByPass -File Win10-Dev-Env.ps1`

---

###What it does:
- Removes a lot of un-necessary items from Windows, disables Defender, Updates, etc
- Installs:
  * Chocolately package Manager, Nuget
  * curl
  * SysInternals
  * Notepad++
  * Postman
  * Packer
  * Atom with several plugins
  * EasyConnect
  * Git and Git extentions GUI
- Optionally installs:
  * ChefDK
  * AzureRM tools for Powershell
  * Hyper-V OR VirtualBox locally
  * Docker tools
  * Vagrant with common provider plugins (Azure, AWS, VMWare, etc)
  * Google Chrome web browser

---

###Notes:
- The default Vagrant provider will be set to "vsphere" unless you choose to install Hyper-V or VirtualBox.  You can change this any time by editing the environment variable "VAGRANT_DEFAULT_PROVIDER".
- If you are using this on a physical box you should review the Win10-Optimize.ps1 and Win10-RemovePackages.ps1 files to see what they do before you say yes to those options.
- You should take a snapshot, checkpoint or equivalent before running this in a VM so that you can revert the changes easily if anything goes wrong.

---

###To do:
- Add shortcuts or something to all of the apps & tools that are installed
- Atom issue "Error: spawn rubocop ENOENT"
- Chef commands not running, probably needs path refreshed after installing ChefDK
- fix "gem" issue, not in path
- Disable OneDrive
- Disable windows updates "from more than one place" - prevent pc from sending updates to other users
- Verify Hyper-V install is working
- Disable hyper-v services if not being used
- Possibly add options for vagrant provider installs - hyper-v, vbox, esx, vmware desktop
- Change windows settings i.e. display hidden files
- Add AWS tools for Powershell
