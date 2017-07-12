#!/bin/bash
# Public cloud GPU ethminer setup

nvidia_drv="NVIDIA-Linux-x86_64-381.22.run"
cuda1="cuda-repo-ubuntu1604-8-0-local-ga2_8.0.61-1_amd64-deb"
cuda2="cuda-repo-ubuntu1604-8-0-local-cublas-performance-update_8.0.61-1_amd64-deb"

minerurl="https://github.com/ethereum-mining/ethminer/releases/download/v0.11.0/ethminer-0.11.0-Linux.tar.gz"
driverurl="http://www.nvidia.com/content/DriverDownload-March2009/confirmation.php?url=/XFree86/Linux-x86_64/381.22/$nvidia_drv"
cuda1url="https://developer.nvidia.com/compute/cuda/8.0/Prod2/local_installers/$cuda1"
cuda2url="https://developer.nvidia.com/compute/cuda/8.0/Prod2/patches/2/$cuda2"

apt update &&\
 apt -y install \
 git screen vim nmap ncdu busybox inxi links unzip python nfs-common xorg \
 build-essential dkms xserver-xorg xserver-xorg-core xserver-xorg-input-evdev \
 xserver-xorg-video-dummy x11-xserver-utils xdm libcurl3 screen

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
nvidia-xconfig --enable-all-gpus
nvidia-xconfig --cool-bits=12

usermod -aG root chris
usermod -aG screen chris

echo "export DISPLAY=:0" >> /home/chris/.bashrc
echo "#!/bin/bash" > /home/chris/.xinitrc
echo "DISPLAY=:0 && xterm -geometry +1+1 -n login" >> /home/chris/.xinitrc
echo "export XAUTHORITY=~/.Xauthority" >> /etc/profile
sed -i -e 's/allowed_users=console/allowed_users=anybody/g' /etc/X11/Xwrapper.config
echo "needs_root_rights=yes" >> /etc/X11/Xwrapper.config

# get ethminer
mkdir /home/chris/ethminer &&\
 cd /home/chris/ethminer && \
 wget $minerurl &&\
 tar -xvf ./ethminer-0.11.0-Linux.tar.gz &&\
 rm ethminer-0.11.0-Linux.tar.gz &&\
 echo "./bin/ethminer -U -S eth-us-west1.nanopool.org:9999 -O 0x96ae82e89ff22b3eff481e2499948c562354cb23.cthulhu --cuda-parallel-hash 4" \
 > ./start_mining.sh &&\
 chmod +x start_mining.sh
