#!/bin/bash

# Chris Diehl
# Setup nVidia Docker

myuser="chris"

# Install nvidia-docker and nvidia-docker-plugin
cd /home/${myuser}
wget -P /tmp https://github.com/NVIDIA/nvidia-docker/releases/download/v1.0.1/nvidia-docker_1.0.1-1_amd64.deb
dpkg -i /tmp/nvidia-docker*.deb && rm /tmp/nvidia-docker*.deb
rm nvidia-docker_1.0.1-1_amd64.deb

# To run a container on GPU 0:
#NV_GPU=0 nvidia-docker run cultclassik/nvminer
# or without nvidia wrapper:
#docker run --device=/dev/nvidiactl --device=/dev/nvidia-uvm --device=/dev/nvidia0

# You must use "nvidia-docker" wrapper to manage GPU containers, rather than just "docker"

# https://github.com/NVIDIA/nvidia-docker/wiki/nvidia-docker-plugin#rest-api
# Each container exposes a rest api, example usage:
# curl -s http://localhost:3476/v1.0/gpu/info
