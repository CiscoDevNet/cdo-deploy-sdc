# Docker Notes

## Best Results
For best results, do not use the docker package supplied by Ubuntu. Instead it is desirable to use the
docker community edition (docker-ce). The install script will provide an opportunity to remove the legacy distro provided docker packages before installing the preferred docker community edition. We will add the official docker apt package repository
and install docker-ce before running the deploy_sdc.sh script. More information on these recommendations and requirements can be found in the official docker documentation [here](https://docs.docker.com/engine/install/ubuntu/#prerequisites).

## Quick Start TLDR;
**Note: Do NOT sudo or run as root!**
```
./install_docker.sh
```

## Manual Steps for Docker Install (Alternative to using the `install_docker.sh` script)
1. Make sure apt package cache is up to date and install some docker pre-requisites
```
sudo apt update
sudo apt install apt-transport-https ca-certificates curl software-properties-common
```
2. Trust the official docker package repository key
Only do ONE of the following, depending on your Ubuntu version:
- Ubuntu < 22.04 (deprecated and less secure key installation)
 ```
 curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
 ```
- Ubuntu >= 22.04
```
curl -s https://download.docker.com/linux/ubuntu/gpg | sudo gpg --no-default-keyring --keyring gnupg-ring:/etc/apt/trusted.gpg.d/docker.gpg --import
sudo chmod 644 /etc/apt/trusted.gpg.d/docker.gpg
```

3. Add the official docker package repository as a package source for apt
In the command below, replace <DISTRO> with the Ubuntu release name. e.g. focal, jammy, etc
```
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu <DISTRO> stable"
```
  
4. Check that we can access the repository and install
```
apt-cache policy docker-ce
sudo apt install docker-ce
```

5. Make sure Docker is installed and up and running
```
sudo systemctl status docker
```
6. Optionally make the current user a docker admin and load the new group permissions
```
sudo usermod -aG docker ${USER}
newgrp docker
```

## Simplified Example of docker-ce manual installation steps on Ubuntu 24.02 (jammy):
```
sudo apt update
sudo apt install apt-transport-https ca-certificates curl software-properties-common awscli -y
curl -s https://download.docker.com/linux/ubuntu/gpg | sudo gpg --no-default-keyring --keyring gnupg-ring:/etc/apt/trusted.gpg.d/docker.gpg --import
sudo chmod 644 /etc/apt/trusted.gpg.d/docker.gpg
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu jammy stable" -y
apt-cache policy docker-ce
sudo apt install docker-ce -y
sudo systemctl status docker 
sudo usermod -aG docker ${USER}
newgrp docker
```