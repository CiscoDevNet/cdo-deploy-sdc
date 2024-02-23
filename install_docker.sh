echo "Checking Ubuntu version..."
source /etc/lsb-release
echo Detected Ubuntu version ${DISTRIB_RELEASE}: ${DISTRIB_CODENAME}

# Uninstall ubuntu provided docker apt packages, if any
packages="docker docker.io docker-compose docker-compose-v2 docker-doc podman-docker"
echo "Do you wish to uninstall any legacy docker packages that may be installed? (Recommended)"
echo "See https://docs.docker.com/engine/install/ubuntu/#prerequisites for more information"
read -r -p "Remove ${packages} [y/N] " response
if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
     for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc
     do
        sudo apt-get remove $pkg -y
     done
fi

# Install needed packages to add docker-ce apt repository
sudo apt update
sudo apt install apt-transport-https ca-certificates curl software-properties-common -y

# Add and trust docker-ce apt repository
if [ ${DISTRIB_CODENAME} == "jammy" ]; then
    curl -s https://download.docker.com/linux/ubuntu/gpg | sudo gpg --no-default-keyring --keyring gnupg-ring:/etc/apt/trusted.gpg.d/docker.gpg --import
    chmod 644 /etc/apt/trusted.gpg.d/docker.gpg
elif [ ${DISTRIB_CODENAME} == "focal" ]; then
   echo "${DISTRIB_CODENAME}: Installing the gpg key for the docker-ce apt repository"
   curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
else
    echo "unable to determine ubuntu release version"
    exit 1
fi
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu ${DISTRIB_CODENAME} stable" -y

# Install the docker community edition (docker-ce)
echo "Installing docker-ce (Community Edition)"
sudo apt install docker-ce -y

# Repoprt the docker daemon status
echo ""
echo "Docker daemon status after installation"
echo $(sudo systemctl status docker | grep 'Active')
echo ""

# Add the current user to the docker permissions group
echo "Adding the current user ${USER} to the docker permmissions group"
sudo usermod -aG docker ${USER}
newgrp docker
echo ""
echo "DONE!"
