# syscripts

This repository contains a collection of scripts I used to automate the setup of a new system.

Very handy for configuring a VM.

Pretty simple Powershell script, this will grow over time.

Note that I use this on Windows 10 Pro, it probably will throw a big malf if you use it on anything else.  You have been warned ;)

To run Win10-Dev-Env.ps1, open Powershell as Administrator and use this command line:
powershell -ExecutionPolicy ByPass -File Win10-Dev-Env.ps1

###To do:
-Add vagrant to path after install, vagrant plugins not working due to this?
-Disable onedrive
-Disable windows updates "from more than one place" - prevent pc from sending updates to other users
-Finish vbox/hyper-v config
-Disable hyper-v services if not being used
-Add options for vagrant provider installs - hyper-v, vbox, esx, vmware desktop
-Change windows settings i.e. display hidden files
