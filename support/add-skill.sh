#!/bin/bash

# Extract repo name from the URL
REPO_NAME=$(basename $1 .git)

echo "Cloning skill $REPO_NAME..."

# Clone the repo if it doesn't exist
if [ ! -d "$REPO_NAME" ]; then
    git clone $1
    if [ $? -ne 0 ]; then
        echo "Error cloning $REPO_NAME."
        exit 1
    fi

    echo "$REPO_NAME cloned successfully."
else
    echo "Repo $REPO_NAME already exists."
fi

# Delete the .git directory
rm -rf "$REPO_NAME/.git"
if [ $? -ne 0 ]; then
    echo "Error deleting .git directory in $REPO_NAME."
    exit 1
fi

exit 0
