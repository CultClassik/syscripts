#!/bin/bash

# Chris Diehl
# Script to install Docker on Ubuntu 14+ ... run as root/sudo

myuser="chris"

# remove any old versions
apt remove -y docker docker-engine docker.io

# install prereqs
apt update &&\
apt install -y \
    linux-image-extra-$(uname -r) \
    linux-image-extra-virtual \
	apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common

# add docker gpg key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

# add official docker repo
add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"
   
# install docker
apt update &&\
 apt install -y docker-ce

# add myuser to docker group 
usermod -aG docker ${myuser}

# ensure it starts on boot
systemctl enable docker

# install compose
curl -L https://github.com/docker/compose/releases/download/$dockerComposeVersion/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
# install completion
curl -L https://raw.githubusercontent.com/docker/compose/master/contrib/completion/bash/docker-compose -o /etc/bash_completion.d/docker-compose
