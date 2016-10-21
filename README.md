# syscripts

This repository contains a collection of scripts I used to automate the setup of a new system.

I  used Matthew Hodgkins's plog post as inspiration (or copy/paste fodder, depending..)

https://hodgkins.io/setup-windows-10-for-chef-and-powershell-dsc-development

Pretty simple Powershell script. Note that I use this on Windows 10 Pro.  Tested on Windows 7 Pro x64 after installing WMF 5.0, no issues.

If you have Git you can clone this repository, although since this installs Git it's better suited to be downloaded as a zip and run from a machine that doesn't have anything installed.

To run Win10-Dev-Env.ps1, open Powershell as Administrator, cd to the posh directory and use this command line:

`powershell -ExecutionPolicy ByPass -File .workstation\Configure-Win10.ps1`

---

###What it does:
- Optionally (although this is one of the main points of this script) installs:
  * Chocolately package Manager, Nuget
  * Git and Git extentions GUI
  * curl
  * Postman
  * Packer
  * Atom editor with some useful packages
- Windows tweaks:
  * For now just some File Explorer settings like show hidden files
- Optionally removes a lot of un-necessary items from Windows
- Optionally installs System Tools:
  * SysInternals
  * Notepad++
  * EasyConnect
- Optionally installs:
  * ChefDK
  * AzureRM tools for Powershell
  * AmazoN AWS tools for Powershell
  * Hyper-V OR VirtualBox locally
  * Docker tools
  * Vagrant with common provider plugins (Azure, AWS, VMWare, etc)

---

###Notes:
- The default Vagrant provider will be set to "vsphere" unless you choose to install Hyper-V or VirtualBox.  You can change this any time by editing the environment variable "VAGRANT_DEFAULT_PROVIDER".  Also, at least with the hyperv provider Vagrant does not appear to support remote virtualization hosts.
- If you are using this on a physical box you should review the Win10-Optimize.ps1 and Win10-RemovePackages.ps1 files to see what they do before you say yes to those options.
- You should take a snapshot, checkpoint or equivalent before running this in a VM so that you can revert the changes easily if anything goes wrong.
- If you click in the Powershell window, you will probably pause execution.  If so, tap the enter key to get it moving again.
- You can run Win10-AtomPkgs.cmd (in a new shell window or from file explorer, not from the same window!) to install useful packages for Atom
- Sometimes PsGet can cause you problems.  If so just delete the PsGet folder from your PowerShell modules folder.  See here for more details: https://til.secretgeek.net/powershell/psget_conflicts_with_PowerShellGet.html
- If you have a need to run more than one hypervisor on one system, it seems that it's best to use VirtualBox as your main hypervisor since it allows passing the VT-x bit along to a guest OS/Hypervisor.
---

###To do:
- Add shortcuts or something to all of the apps & tools that are installed
- Disable windows updates "from more than one place" - prevent pc from sending updates to other users
- Disable hyper-v services if not being used
- Possibly add options for vagrant provider installs - hyper-v, vbox, esx, vmware desktop
- Enable telnet client feature
