#!/bin/bash
# Script to update a Git repository, rebuild Docker containers, and copy theme files.

# Configuration
REPO_URL="https://github.com/Honeytg/Cloud-Application.git"
DOCKER_SUBDIR="/home/ec2-user/wordpress-docker"
CONTAINER_NAME="wordpress-app" # Used for docker cp and restart commands
THEME_DIR="/var/www/html/wp-content/themes/customwp"

echo "=========================================="
echo " Starting Automated WordPress Deployment"
echo "=========================================="

# go to wordpress-docker directory
cd /home/ec2-user/wordpress-docker

#git pull
sudo git pull

sleep 10 

#pull latest image and recreate docker
docker-compose up -d

sleep 15

#copy all the files
docker cp ./index.php wordpress-app:/var/www/html/wp-content/themes/customwp/
docker cp ./functions.php wordpress-app:/var/www/html/wp-content/themes/customwp/
docker cp ./style.css wordpress-app:/var/www/html/wp-content/themes/customwp/

#restart docker container
docker restart wordpress-app

sleep 5

echo "=========================================="
echo " Deployment Script Finished"
echo "=========================================="