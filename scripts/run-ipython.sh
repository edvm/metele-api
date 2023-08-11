#!/bin/bash

if [ ! -d "./app" ]; then
    echo "You must run this script from the root of the project."
    exit 1
fi
source ./venv/bin/activate

pip install --upgrade pip
pip install ipython

# If needed, uncomment the following lines to load environment variables from a .env file
# so that they are available in the IPython shell.

# Read the line from the .env file
# foo_key=$(grep "^FOO_KEY=" "./.env" | cut -f2 -d "=" | sed 's/"//g')

# Extract the value after the equals sign
# export FOO_KEY=${foo_key}

# echo "Loaded Environment variables:"
# echo "FOO_KEY: $FOO_KEY"

PYTHONPATH=`pwd`/app ipython
