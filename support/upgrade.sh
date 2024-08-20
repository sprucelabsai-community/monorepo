#!/bin/bash

echo "Upgrading skills..."

# if any arguments are passed, we'll use upgrade-skill.sh
if [ $# -ge 1 ]; then
    ./support/upgrade-skill.sh "$@"
    exit 0
fi

cd ./packages

for dir in *-skill; do
    if [[ -d $dir ]]; then
        cd "$dir"

        # if pull fails, bail
        git pull || exit 1

        # Upgrade skill
        spruce upgrade

        cd ..
    fi
done

# if spruce-mercury-api exists, do the same thing but run "yarn upgrade.packages.all" instead of "spruce upgrade"
if [[ -d "spruce-mercury-api" ]]; then
    cd "spruce-mercury-api"
    git pull
    yarn upgrade.packages.all
    yarn build.dev
fi
