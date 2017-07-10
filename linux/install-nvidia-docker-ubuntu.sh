#!/bin/bash

# Chris Diehl
# Setup nVidia Docker

myuser="chris"

# Install nvidia-docker and nvidia-docker-plugin
cd /home/${myuser}
wget -P /tmp https://github.com/NVIDIA/nvidia-docker/releases/download/v1.0.1/nvidia-docker_1.0.1-1_amd64.deb
dpkg -i /tmp/nvidia-docker*.deb && rm /tmp/nvidia-docker*.deb
rm nvidia-docker_1.0.1-1_amd64.deb
