#!/bin/bash

# Usage message
usage() {
    echo "Usage: $0 path/to/blueprint [PARAMETER=value]..."
}

# Parse positional arguments
BLUEPRINT=$1
shift # Remove the first argument, leaving only options and parameters

if [ -z "$BLUEPRINT" ]; then
    usage
    exit 1
fi

# Parse options and parameters
while [ $# -gt 0 ]; do
    case "$1" in
    *=*)
        # Assuming arguments are in the form PARAMETER=value
        key="${1%%=*}"
        value="${1#*=}"

        echo "Importing variable: $key as $value"

        # Export parameter for later use in sed command
        export "$key"="$value"
        ;;
    *)
        # Unknown option
        echo "Unknown option: $1"
        usage
        exit 1
        ;;
    esac
    shift
done

echo "Processing blueprint: $BLUEPRINT"

# Convert BLUEPRINT to blueprint.yml in the base directory
cp "$BLUEPRINT" blueprint.yml

# Detect the operating system
OS=$(uname)

# Replace parameters in the blueprint.yml
while IFS= read -r line; do
    if [[ "$line" =~ \$([a-zA-Z_][a-zA-Z_0-9]*) ]]; then # Match $ followed by variable name
        param="${BASH_REMATCH[1]}"
        # Check if the variable is set using an older method
        if [ ! -z "${!param}" ]; then # Check if variable is set
            if [[ "$OS" == "Darwin" ]]; then
                # Use sed suitable for macOS. Notice the '' after -i, which is required for macOS
                sed -i '' "s|\$$param|${!param}|g" blueprint.yml
            else
                # Use sed suitable for Linux
                sed -i "s|\$$param|${!param}|g" blueprint.yml
            fi
        fi
    fi
done <blueprint.yml

# Check for uncaught parameters in blueprint.yml and list them
uncaught_params=$(grep -o '\$[a-zA-Z_][a-zA-Z_0-9]*' blueprint.yml | sort | uniq)
if [ -n "$uncaught_params" ]; then
    echo "Error: Missing dynamic parameters detected in blueprint.yml."
    echo "These parameters can be passed via command line e.g. "
    echo "Usage: yarn import blueprint [...] PARAMETER1=value1 ..."
    echo "$uncaught_params"
    exit 1
fi

# Loop through every dir inside of packages
# and run ./propagate-blueprint.sh {dir} {blueprint} with "--configStrategy=replace"
for dir in packages/*; do
    if [ -d "$dir" ]; then
        ./support/propagate-blueprint.sh "$dir" blueprint.yml "--configStrategy=replace"
    fi
done
