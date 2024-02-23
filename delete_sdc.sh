#!/bin/bash

# Remove sdc crontab
sudo -u sdc crontab -r

# Stop and remove SDC and SEC docker containers
docker ps -a | grep projectlockhart-docker | cut -f1 -d' ' | xargs docker stop | xargs docker rm

# Delete SDC and SEC docker images
docker images | grep projectlockhart-docker | tr -s " " | cut -f3 -d' ' | xargs docker image rm

# Delete sdc user's home directory (And all SDC/SEC data and bootstrap info)
sudo rm -Rf /usr/local/cdo

echo "You may also wish to remove the sdc user from your system by running 'sudo deluser sdc'"
echo "You now have a clean environment to run the 'deploy_sdc.sh' script again, if desired."
