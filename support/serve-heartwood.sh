#!/bin/bash

# Set DIR to the current working directory
DIR="$(pwd)"

source ./support/hero.sh

# Define the path to the heartwood-skill directory
heartwood_skill_dir="$DIR/packages/spruce-heartwood-skill/dist"

# Check if the heartwood-skill directory exists
if [ ! -d "$heartwood_skill_dir" ]; then
    echo "Error: The $heartwood_skill_dir directory does not exist. You may need to run 'yarn build.heartwood'."
    exit 1
fi

# Create a Caddyfile
echo ":8080
bind 0.0.0.0
root * $heartwood_skill_dir
file_server" >Caddyfile

# Run Caddy
caddy run >/dev/null &

clear

hero "Heartwood is now serving at http://localhost:8080"
