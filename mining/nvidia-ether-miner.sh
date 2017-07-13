#!/bin/bash
# Chris Diehl
# GPU ethminer setup for NVidia GPU systems - use root or sudo

# Commands to overclock (should be added to a script later):
#sudo nvidia-settings -c :0 -a [gpu:<GPU_INDEX>]/GPUMemoryTransferRateOffset[3]=<MEM_CLK_SPEED_INCREASE>
#sudo nvidia-settings -c :0 -a [gpu:<GPU_INDEX>]/GPUGraphicsClockOffset[3]=<CORE_CLK_SPEED_INCREASE>
myuser="chris"
ethcmdline="./bin/ethminer -U -S eth-us-west1.nanopool.org:9999 -O 0x96ae82e89ff22b3eff481e2499948c562354cb23.cthulhu --cuda-parallel-hash 4"
nvidia_drv="NVIDIA-Linux-x86_64-381.22.run"
cuda1="cuda-repo-ubuntu1604-8-0-local-ga2_8.0.61-1_amd64-deb"
cuda2="cuda-repo-ubuntu1604-8-0-local-cublas-performance-update_8.0.61-1_amd64-deb"

minerurl="https://github.com/ethereum-mining/ethminer/releases/download/v0.11.0/ethminer-0.11.0-Linux.tar.gz"
driverurl="http://www.nvidia.com/content/DriverDownload-March2009/confirmation.php?url=/XFree86/Linux-x86_64/381.22/$nvidia_drv"
cuda1url="https://developer.nvidia.com/compute/cuda/8.0/Prod2/local_installers/$cuda1"
cuda2url="https://developer.nvidia.com/compute/cuda/8.0/Prod2/patches/2/$cuda2"

apt update &&\
 apt -y install \
   git screen vim nmap ncdu busybox inxi links unzip python nfs-common \
   xorg xorg-dev xserver-xorg xserver-xorg-core xserver-xorg-input-evdev xdm \
   xserver-xorg-video-dummy x11-xserver-utils \
   xdm libcurl3 build-essential dkms

 # Download drivers and Cuda toolkit
 cd ~/
 mkdir drivers &&\
  cd drivers
 wget $driverurl
 wget $cuda1url
 wget $cuda2url

# install cuda
dpkg -i $drvpath/$cuda1
dpkg -i $drvpath/$cuda2

# install driver
chmod +x $drvpath/$nvdrv
$drvpath/$nvdrv --no-install-compat32-libs

# change some settings
update-grub
#nvidia-xconfig --enable-all-gpus
#nvidia-xconfig --cool-bits=12
 nvidia-xconfig -a --allow-empty-initial-configuration --cool-bits=28 --use-display-device="DFP-0" --connected-monitor="DFP-0"

usermod -aG root $myuser
usermod -aG video $myuser

echo "export DISPLAY=:0" >> /home/$myuser/.bashrc
echo "#!/bin/bash" > /home/$myuser/.xinitrc
echo "DISPLAY=:0 && xterm -geometry +1+1 -n login" >> /home/$myuser/.xinitrc
echo "export XAUTHORITY=~/.Xauthority" >> /etc/profile
sed -i -e 's/allowed_users=console/allowed_users=anybody/g' /etc/X11/Xwrapper.config
echo "needs_root_rights=yes" >> /etc/X11/Xwrapper.config

# get ethminer
mkdir /home/$myuser/ethminer &&\
 cd /home/$myuser/ethminer && \
 wget $minerurl &&\
 tar -xvf ./ethminer-0.11.0-Linux.tar.gz &&\
 rm ethminer-0.11.0-Linux.tar.gz &&\
 echo $ethcmdline \
 > ./start_mining.sh &&\
 chmod +x start_mining.sh
