#!/bin/bash

# Check if at least one command line argument is provided
if [ "$#" -lt 1 ]; then
    echo "Usage: $0 path_to_theatre_zip [--shouldIncludeConfig path_to_config_zip]"
    exit 1
fi

# Get the path to the theatre zip file from the command line argument
THEATRE_ZIP="$1"

# Initialize variables for config zip handling
SHOULD_INCLUDE_CONFIG=false
CONFIG_ZIP=""

# Check if additional arguments are provided for config
if [ "$#" -eq 3 ] && [ "$2" == "--shouldIncludeConfig" ]; then
    SHOULD_INCLUDE_CONFIG=true
    CONFIG_ZIP="$3"
fi

# Check if the theatre zip file exists
if [ ! -f "$THEATRE_ZIP" ]; then
    echo "Theatre zip file does not exist: $THEATRE_ZIP"
    exit 1
fi

# Perform a backup using yarn export.theatre with the --backup and --shouldIncludeConfig flags
echo "Performing backup..."
yarn export.theatre --backup --shouldIncludeConfig

# Remove the existing 'packages' and 'node_modules' directories
echo "Removing existing theatre and node_modules..."
rm -rf packages node_modules

# Define the base directory as the current directory
BASE_DIR="."

# Extract the theatre contents
echo "Importing new theatre files..."
unzip -qo "$THEATRE_ZIP" -d "$BASE_DIR"
echo "Theatre has been imported to $BASE_DIR"

# Check and handle config zip if specified
if $SHOULD_INCLUDE_CONFIG; then
    if [ ! -f "$CONFIG_ZIP" ]; then
        echo "Config zip file does not exist: $CONFIG_ZIP"
        exit 1
    else
        # Extract the config contents
        echo "Importing new config files..."
        unzip -qo "$CONFIG_ZIP" -d "$BASE_DIR"
        echo "Config has been imported to $BASE_DIR"
    fi
fi

zsh -c "source ~/.zshrc; env > /tmp/zshenv"
source /tmp/zshenv

# This has to get reinstalled after the theatre is imported
npm uninstall pm2

npm install pm2
