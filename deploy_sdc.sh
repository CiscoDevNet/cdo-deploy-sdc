#!/bin/bash

# The sdc user's home directory
sdc_home=/usr/local/cdo

# We need the b64 bootstrap payload from CDO as a parameter for the script
if [ "$#" -ne 1 ]; then
    echo "usage: source deploy_sdc.sh [bootstrap data]" >&2
    echo "example: source deploy_sdc.sh Q0RPX1RPS0VOPSJleU...Y29fYWFoYWNrbmUtU0RDLTQiCg==" >&2
    exit
fi

# Make sure the bootstrap.sh prerequisite packages are installed
for package in net-tools awscli
do
  if [ ! "$(sudo dpkg -l | awk '/'"$package"'/ {print }'|wc -l)" -ge 1 ]; then
    echo "$package is required for the CDO SDC bootstrap script and is not installed."
    echo "Installing $package"
    sudo apt-get install "$package" -y
  fi
done

# Create sdc user if it does not exist
if id sdc >/dev/null 2>&1; then
    echo "Found existing user: sdc"
else
    echo "Creating user: sdc"
    sudo adduser --gecos "" --disabled-password sdc --home "$sdc_home"
fi

# Make sure the sdc user's home dir exists
if [ ! -d /usr/local/cdo ]; then
    sudo mkdir "$sdc_home"
    sudo chown sdc:sdc "$sdc_home"
fi

# Create the docker group if it does not exist
if [ $(getent group docker) ]; then
    echo "Found existing group: docker"
else
    echo "Creating group: docker"
    sudo groupadd docker
fi

# Add the sdc user to the docker group
echo "Adding the sdc user to the group docker"
if [ ! $(getent group docker | grep -qw "sdc")]; then
    sudo usermod -aG docker sdc
fi

# Check for the docker daemon.json file
echo "Checking to see if the file daemon.json file exists in /etc/docker"
daemon_json='{"live-restore": true, "group": "docker"}'

if [ -f /etc/docker/daemon.json ]; then
  echo "/etc/docker/daemon.json exists. Please make sure the following parameters are in /etc/docker/daemon.json"
  echo $daemon_json
else
  echo "Writing file /etc/docker/daemon.json"
  echo ${daemon_json} > daemon.json
  sudo cp daemon.json /etc/docker/daemon.json
  rm daemon.json
fi

# Restart the docker daemon
echo "Restarting docker daemon"
sudo systemctl restart docker
echo "Docker status after restart:"
echo $(sudo systemctl status docker | grep 'Active')

# Decode bootstrap data and extract the needed pieces
echo "Decoding the bootstrap data..."
decoded_bootstrap=$(echo "$1" | base64 --decode)

# Write env vars to file for the sdc and also load the vars
printf '%s\n' ${decoded_bootstrap} > sdcenv
source sdcenv
rm sdcenv

# Download the bootstrap file from CDO
echo Downloading CDO Bootstrap File
sudo curl --output "$sdc_home/${CDO_BOOTSTRAP_URL##*/}" --header "Authorization: Bearer ${CDO_TOKEN}" "$CDO_BOOTSTRAP_URL"

# Untarring CDO Bootstrap file
sudo tar xzvf "$sdc_home/${CDO_BOOTSTRAP_URL##*/}" --directory "$sdc_home"

# Remove the tar file
sudo rm "$sdc_home/${CDO_BOOTSTRAP_URL##*/}"

# chown the new files to sdc user
sudo chown --recursive sdc:sdc "$sdc_home"

# Final check for success and exit
if sudo test -f "${sdc_home}/bootstrap/bootstrap.sh"; then
  echo
  echo "***********************************************************************************************"
  echo "SDC pre-configuration scripts appears to have completed successfully."
  echo "Running the CDO SDC Bootstrap script to finsh the deployment process:"
  # Export vars to pass into the bootstrap script via sudo
  export CDO_TOKEN=$CDO_TOKEN
  export CDO_DOMAIN=$CDO_DOMAIN
  export CDO_TENANT=$CDO_TENANT
  export CDO_BOOTSTRAP_URL=$CDO_BOOTSTRAP_URL
  export HOME=/usr/local/cdo
  # Patch common.sh to use absoulte path for needed files...
  sudo -Eu sdc sed -i '6s/.*/env_dir=$(dirname $(readlink -f $0))/' /usr/local/cdo/bootstrap/common.sh
  # Execute bootstrap script
  sudo -Eu sdc ${sdc_home}/bootstrap/bootstrap.sh
  echo "Check that the docker container 'sdc_prod:ubuntu' is up and running..."
  sudo -Eu sdc docker ps
  echo "If the docker container is up and running, the status of the SDC should go to 'Active' in the CDO Event Connectors panel."
else
  echo "***********************************************************************************************" >&2
  echo "Something went wrong with the pre-configuration script." >&2
  echo "Post your issue in [github](https://github.com/CiscoDevNet/cdo-deploy-sdc/issues) and include the output from this script with the debug option enabled being sure ** NOT to post any passwords or API keys**!" >&2
  echo "bash -x sdc-pre-config.sh" >&2
  echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++" >&2
fi
