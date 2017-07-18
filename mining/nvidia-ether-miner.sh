#!/bin/bash
# Chris Diehl
# GPU ethminer setup for NVidia GPU systems - use root or sudo

# make sure to add to script - keeping a gpu context
# https://sites.google.com/site/akohlmey/random-hacks/nvidia-gpu-coolness#TOC-Running-nvidia-settings

# reference
# https://docs.google.com/document/d/1fDLin250wgNPLMh0uLYMQksa1Bjje5KF-d9KrHBjKf4/edit
# https://askubuntu.com/questions/38780/how-do-i-set-nomodeset-after-ive-already-installed-ubuntu (nomodeset for grub)
# https://wiki.archlinux.org/index.php/NVIDIA/Tips_and_tricks#Enabling_overclocking
# https://forum.ethereum.org/discussion/7780/gtx1070-linux-installation-and-mining-clue-goodbye-amd-welcome-nvidia-for-miners
# https://blockoperations.com/build-6-gpu-zcash-headless-mining-rig-ubuntu-16-04-using-claymore/
# https://hashcat.net/forum/thread-5761-post-30898.html
# https://gist.github.com/bsodmike/369f8a202c5a5c97cfbd481264d549e9
# https://www.reddit.com/r/EtherMining/comments/6hvf67/nvidia_linux_overclocks/dj1nevd/

# Commands to overclock (should be added to a script later):
#sudo nvidia-settings -c :0 -a [gpu:<GPU_INDEX>]/GPUMemoryTransferRateOffset[3]=<MEM_CLK_SPEED_INCREASE>
#sudo nvidia-settings -c :0 -a [gpu:<GPU_INDEX>]/GPUGraphicsClockOffset[3]=<CORE_CLK_SPEED_INCREASE>

myuser="chris"
ethcmdline="./bin/ethminer -U -S eth-us-west1.nanopool.org:9999 -O 0x96ae82e89ff22b3eff481e2499948c562354cb23.cthulhu --cuda-parallel-hash 4"

gpucoreoc="-100"
gpumemoc="700"
gpupl="65"
gpufanspd="60"

nvidia_drv="NVIDIA-Linux-x86_64-381.22.run"
cuda1="cuda-repo-ubuntu1604-8-0-local-ga2_8.0.61-1_amd64-deb"
cuda2="cuda-repo-ubuntu1604-8-0-local-cublas-performance-update_8.0.61-1_amd64-deb"

minerurl="https://github.com/ethereum-mining/ethminer/releases/download/v0.11.0/ethminer-0.11.0-Linux.tar.gz"
driverurl="http://us.download.nvidia.com/XFree86/Linux-x86_64/381.22/$nvidia_drv"
cuda1url="https://developer.nvidia.com/compute/cuda/8.0/Prod2/local_installers/$cuda1"
cuda2url="https://developer.nvidia.com/compute/cuda/8.0/Prod2/patches/2/$cuda2"

apt update &&\
 apt -y install \
   git screen vim nmap ncdu busybox inxi links unzip python nfs-common libcurl3 build-essential dkms \
   xorg xorg-dev xserver-xorg xserver-xorg-core xserver-xorg-input-evdev xdm xserver-xorg-video-dummy x11-xserver-utils xdm gtk2.0

 # Download drivers and Cuda toolkit
 cd ~/
 mkdir drivers &&\
  cd drivers
 wget $driverurl
 wget $cuda1url
 wget $cuda2url

# install cuda
cd $drvpath
dpkg -i $cuda1
dpkg -i $cuda2

# install driver
cd $drvpath
chmod +x $nvidia_drv
$drvpath/$nvidia_drv --no-install-compat32-libs

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
 chown -R $myuser:$muser ./*
 chmod +x start_mining.sh

# Enable power limit for GPUs and set the value
 nvidia-smi -pm ENABLED &&\
  nvidia-smi -pl $gpupl

# Find all Nvidia GPUs
gpu_count=0
IFS='\n'
gpus=($(nvidia-smi -L))
for x in "${gpus[@]}"; do gpu_count=$(( $gpu_count + 1 )); done
count=$((gpu_count+1))
echo "Found $count NVidia GPUs"

# set fan speed and overclock settings for all cards
for ((i=0; i < $count; ++i))
do
  nvidia-settings -a "[gpu:$i]/GPUGraphicsClockOffset[3]=$gpucoreoc" \
    -a "[gpu:$i]/GPUMemoryTransferRateOffset[3]=$gpumemoc" \
    -a "[gpu:$i]/GPUFanControlState=1" \
    -a "[fan:$i]/GPUTargetFanSpeed=$gpufanspd" \
    -a GPUPowerMizerMode=1
done
