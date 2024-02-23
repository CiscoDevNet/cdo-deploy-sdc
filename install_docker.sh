#!/bin/bash

echo "Installing docker-ce"

# Install needed packages to add docker-ce apt repository
sudo apt update
sudo apt install apt-transport-https ca-certificates curl software-properties-common -y

# Add docker-ce apt repository
curl -s https://download.docker.com/linux/ubuntu/gpg | sudo gpg --no-default-keyring --keyring gnupg-ring:/etc/apt/trusted.gpg.d/docker.gpg --import
sudo chmod 644 /etc/apt/trusted.gpg.d/docker.gpg
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu jammy stable" -y

# Verify we can hit the docker-ce apt repository
echo "Testing access to the docker-ce apt repository"
apt-cache policy docker-ce

# Install docker-ce from docker-ce apt repository
sudo apt install docker-ce -y

# Add the current user to the docker group and add to users current login session groups
sudo usermod -aG docker ${USER}
newgrp docker

# Verify docker is up and running
echo "Current docker daemon status:"
echo `sudo systemctl status docker | grep 'Active'`
