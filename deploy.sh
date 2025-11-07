#!/bin/bash
# Script to update a Git repository, rebuild Docker containers, and copy theme files.

# Configuration
REPO_URL="https://github.com/Honeytg/Cloud-Application.git"
DOCKER_SUBDIR="wordpress-docker"
CONTAINER_NAME="wordpress-app" # Used for docker cp and restart commands
THEME_DIR="/var/www/html/wp-content/themes/customwp"

echo "=========================================="
echo " Starting Automated WordPress Deployment"
echo "=========================================="

# 1. Handle Repository (Clone or Pull)
if [ -d "$DOCKER_SUBDIR" ]; then
    echo "1. Repository '$DOCKER_SUBDIR' already exists. Pulling latest changes..."
    cd "$DOCKER_SUBDIR"
    # Ensure all branches are updated
    sudo git pull
    if [ $? -ne 0 ]; then
        echo "ERROR: Git pull failed."
        exit 1
    fi
else
    echo "1. Cloning repository: $REPO_URL"
    # Clone and CD into the repo
    sudo git clone "$REPO_URL"
    if [ $? -ne 0 ]; then
        echo "ERROR: Git clone failed."
        exit 1
    fi
    cd "$DOCKER_SUBDIR"
fi

# 2. Change into the Docker directory
if [ -d "$DOCKER_SUBDIR" ]; then
    echo "2. Changing directory to $DOCKER_SUBDIR"
    cd "$DOCKER_SUBDIR"
else
    echo "ERROR: Docker subdirectory '$DOCKER_SUBDIR' not found inside the repository."
    exit 1
fi

# 3. Pull and Recreate Docker Containers
echo "3. Pulling latest Docker images..."
sudo docker-compose pull

echo "4. Recreating and starting the 'wordpress' service in detached mode..."
# The --force-recreate flag ensures the container is always rebuilt
sudo docker-compose up -d --force-recreate wordpress
if [ $? -ne 0 ]; then
    echo "ERROR: Docker Compose failed to start the 'wordpress' service."
    exit 1
fi

# 4. Copy custom theme files and restart
echo "5. Checking if container '$CONTAINER_NAME' is running to copy files..."

# Give the container a moment to start up
sleep 5

if sudo docker ps --format '{{.Names}}' | grep -q "$CONTAINER_NAME"; then
    echo "   -> Container found. Creating custom theme directory: $THEME_DIR"
    # Create the target theme directory inside the container
    sudo docker exec "$CONTAINER_NAME" mkdir -p "$THEME_DIR"

    # Copy files from the local directory (assumed to be within wordpress-docker/) to the container
    echo "   -> Copying index.php, style.css, and functions.php..."
    sudo docker cp index.php "$CONTAINER_NAME":"$THEME_DIR"/index.php
    sudo docker cp style.css "$CONTAINER_NAME":"$THEME_DIR"/style.css
    sudo docker cp functions.php "$CONTAINER_NAME":"$THEME_DIR"/functions.php
    echo "   -> Files copied successfully."

    # Restart the container to ensure PHP/web server picks up the new files
    echo "6. Restarting the container: $CONTAINER_NAME"
    sudo docker restart "$CONTAINER_NAME"
else
    echo "WARNING: Container '$CONTAINER_NAME' is not running or not found. Skipping file copy and restart."
fi

echo "=========================================="
echo " Deployment Script Finished"
echo "=========================================="