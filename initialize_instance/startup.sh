#!/bin/bash

checkfile=".startup-has-executed"

if [ -f $checkfile ]; then 
	exit
fi

# this is to avoid the startup script running twice
sudo touch .startup-has-executed 

# Put the script output somewhere we can go and have a look at it.
exec > /var/log/startup-script.log 2>&1
set -ex


sudo apt-get update
sudo apt-get install -y ubuntu-drivers-common vim unzip
sudo ubuntu-drivers autoinstall

sudo apt-get install -y nvidia-driver-535

#
# Docker install 
#

echo "\n\nnvidia drivers succesfully installed\n\n\n"

#
# Note, needed to reboot here as code needed to be run manually after here. (i.e. didn't work from startup script)
# I will need to fix this later on
# 

sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-cache policy docker-ce
sudo apt-get install -y docker-ce

echo "\n\ndocker succesfully installed\n\n\n"

# Ways to get docker to run without pre-pending sudo require password, skipping for now 
#todo later

#
# Install CUDA container
#

curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg \
  && curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | \
    sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
    sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list

sudo apt-get update

export NVIDIA_CONTAINER_TOOLKIT_VERSION=1.17.8-1
  sudo apt-get install -y \
      nvidia-container-toolkit=${NVIDIA_CONTAINER_TOOLKIT_VERSION} \
      nvidia-container-toolkit-base=${NVIDIA_CONTAINER_TOOLKIT_VERSION} \
      libnvidia-container-tools=${NVIDIA_CONTAINER_TOOLKIT_VERSION} \
      libnvidia-container1=${NVIDIA_CONTAINER_TOOLKIT_VERSION}


echo "\n\nnvidia-container succesfully installed\n\n\n"

# to test the install, you can run the following: sudo docker run --rm --runtime=nvidia --gpus all ubuntu nvidia-smi

echo "\n\nstartup.sh succesfully completed."

sudo reboot


