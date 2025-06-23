#!/usr/bin/env bash

# Activate your Python virtual environment
source /home/aditya/venvs/312/bin/activate

# Prompt for the Python object to look up
read -p "Enter Python object to look up: " query

# Exit if nothing entered
if [[ -z "$query" ]]; then
    echo "No input provided. Exiting."
    exit 1
fi

# Run pydoc and pipe output to less for scrolling
pydoc "$query" | less
