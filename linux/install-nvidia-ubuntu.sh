#!/bin/bash

nvidia_drv="nvidia-381"

drvpath="/mnt/software/Drivers"
cuda1="cuda-repo-ubuntu1604-8-0-local-ga2_8.0.61-1_amd64-deb"
cuda2="cuda-repo-ubuntu1604-8-0-local-cublas-performance-update_8.0.61-1_amd64-deb"
nvdrv="NVIDIA-Linux-x86_64-375.66.run"

# add the nvidia driver ppa
add-apt-repository ppa:graphics-drivers/ppa

apt update &&\
 apt -y install \
 git screen vim nmap ncdu busybox inxi links unzip python nfs-common xorg \
 build-essential dkms xserver-xorg xserver-xorg-core xserver-xorg-input-evdev \
 xserver-xorg-video-dummy x11-xserver-utils xdm libcurl3
 
mkdir /mnt/software
echo "nastee.diehlabs.lan:/software    /mnt/software    nfs     defaults        0       0" >> /etc/fstab
mount -a

# install cuda
dpkg -i $drvpath/$cuda1
dpkg -i $drvpath/$cuda2

# install driver
$drvpath/$nvdrv
# may change to :
# apt install -y $nvidia_drv

# change some settings
nvidia-xconfig --enable-all-gpus
nvidia-xconfig --cool-bits=12

usermod -aG root chris
echo "force_color_prompt=yes" >> /home/chris/.bashrc
echo "LS_COLORS=$LS_COLORS:'di=0;36:' ; export LS_COLORS" >> /home/chris/.bashrc
echo "export DISPLAY=:0" >> /home/chris/.bashrc

echo "#!/bin/bash" > /home/chris/.xinitrc
echo "DISPLAY=:0 && xterm -geometry +1+1 -n login" >> /home/chris/.xinitrc

echo "export XAUTHORITY=~/.Xauthority" >> /etc/profile

sed -i -e 's/allowed_users=console/allowed_users=anybody/g' /etc/X11/Xwrapper.config
echo "needs_root_rights=yes" >> /etc/X11/Xwrapper.config

# get ethminer
mkdir /home/chris/ethminer &&\
 cd /home/chris/ethminer && \
 wget https://github.com/ethereum-mining/ethminer/releases/download/v0.11.0/ethminer-0.11.0-Linux.tar.gz &&\
 tar -xvf ./ethminer-0.11.0-Linux.tar.gz &&\
 rm ethminer-0.11.0-Linux.tar.gz &&\
 echo "./bin/ethminer -U -S eth-us-west1.nanopool.org:9999 -O 0x96ae82e89ff22b3eff481e2499948c562354cb23.cthulhu --cuda-parallel-hash 4" \
 > ./start_mining.sh &&\
 chmod +x start_mining.sh

# settings for evga 1060 6g ftw
nvidia-smi -pm ENABLED
nvidia-smi -pl 75

nvidia-settings -a GPUPowerMizerMode=1 -a GPUFanControlState=1 -a GPUGraphicsClockOffset[3]=100

nvidia-settings -a '[gpu:0]/GPUMemoryTransferRateOffset[3]=1200' &&\
 nvidia-settings -a '[gpu:0]/GPUGraphicsClockOffset[3]=100'


nvidia-settings -a '[gpu:0]/GPUFanControlState=1' &&\
 nvidia-settings -a '[fan:0]/GPUTargetFanSpeed=60'

# use below to allow nvidia changes, maybe that's what screen is for..
 X :1 &
export DISPLAY=:1
nvidia-settings your-params
killall X
