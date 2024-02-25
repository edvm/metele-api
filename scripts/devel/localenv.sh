#!/bin/bash

# Set the log level for the application. Only used when running the application in debug mode
# (i.e. when running the application with the 'debug' command)
export LOGURU_LEVEL=DEBUG

# List of services that are expected to be running when running pytest
# i.e. PYTEST_REQUIRED_RUNNING_CONTAINERS=("postgres1" "test3" "test2")
PYTEST_REQUIRED_RUNNING_CONTAINERS=()

# Command to run the linter.
LINTER_CMD="rye run black ."


# Function to run if an `.env` file exists, to load environment variables
# If it doesn't exists, exit with an error message.
function load_env() {
    if [ -f .env ]; then
        source .env
    else
        echo "You must create a .local.env file with the environment variables:"
        echo " - HOST (e.g. localhost, used when running the application in debug mode)"
        echo " - PORT (e.g. 8000, used when running the application in debug mode)"
        echo " - PROJECT_NAME (the name of the docker container that'll be created)"
        echo " - NETWORK_NAME (optional, the name of the docker network the container will be connected to)"
        exit 1
    fi

    if [ -z "$HOST" ]; then
        echo "The HOST environment variable is not set."
        exit 1
    fi

    if [ -z "$PORT" ]; then
        echo "The PORT environment variable is not set."
        exit 1
    fi

    if [ -z "$PROJECT_NAME" ]; then
        echo "The PROJECT_NAME environment variable is not set."
        exit 1
    fi

    if [ -z "$NETWORK_NAME" ]; then
        NETWORK_NAME="bridge"
        echo "NETWORK_NAME is not set. Using the default network: $NETWORK_NAME"
    fi
}


# Function to check we are running the script from the root of the project
function check_root() {
    if [ ! -d "./app" ]; then
        echo "You must run this script from the root of the project."
        exit 1
    fi
    load_env
}

# Function to check if the virtual environment exists
function check_venv() {
    if [ ! -d "./.venv" ]; then
        echo "No virtual environment found. Be sure to run 'rye sync' before running this command."
        exit 1
    fi
}

function rye_installed() {
  if [ -f "$HOME/.rye/env" ]; then
    return 0
  else
    return 1
  fi
} 

# Function to activate the virtual environment
function activate_venv() {
    if ! rye_installed; then
        echo "Rye is not installed. Please install it and try again."
        echo "It should be installed by the install.sh script."
        exit 1
    fi
    source $HOME/.rye/env
    . ./.venv/bin/activate
}

# Function to run pytest
function run_pytest() {
    # Check that services defined in EXPECTED_RUNNING_DOCKER_SERVICES are running
    for service in "${PYTEST_REQUIRED_RUNNING_CONTAINERS[@]}"; do
        if ! docker ps --format '{{.Names}}' | grep -q "^$service$"; then
            echo "Error: '$service' container is not running."
            echo "Please be sure to start the 'devops-docker' project before running this command."
            exit 1
        fi
    done
    shift  # remove `pytest` from the args
    echo "To be implemented"
    # docker run -it -v `pwd`/src:/app/src/ --rm --network some-network container-name pytest -vv "$@"
}

# Function to run the application in debug mode
function run_debug() {
    check_root
    check_venv
    activate_venv
    PYTHONPATH=`pwd`/app hypercorn --bind "$HOST:$PORT" --reload main:app
}


# Run install script. Calls the install.sh script with the required Python version as an argument.
function run_install() {
    check_root
    chmod +x ./scripts/devel/install.sh
    ./scripts/devel/install.sh
}


if [[ "$1" == "debug" ]]; then
    run_debug
elif [[ "$1" == "install" ]]; then
    run_install
elif [[ "$1" == "up" ]]; then
    docker compose up --build --remove-orphans
elif [[ "$1" == "pytest" ]]; then
    run_pytest "$@"
elif [[ "$1" == "ipython" ]]; then
    echo "To be implemented"
#   docker run -it -v `pwd`/src:/app/src/ --rm --network some-network container-name bash -c "export PYTHONPATH=/app/src && pip install ipython && cd /app/src && ipython -i tests/e2e/dbshell.py"
elif [[ "$1" == "down" ]]; then
    docker compose -v down 
elif [[ "$1" == "lint" ]]; then
    check_root
    check_venv
    activate_venv
    cd ./app
    echo "Running linter..."
    eval $LINTER_CMD
else
    # echo -e "Usage: localenv.sh [\e[0m\e[32mup\e[0m\e[32m|\e[0m\e[32mdown\e[0m\e[32m|\e[0m\e[32mpytest\e[0m\e[32m|\e[0m\e[32mdebug\e[0m\e[32m|\e[0m\e[32mipython\e[0m\e[32m|\e[0m\e[32mlint\e[0m\e[32m]\e[0m"
    echo -e "Usage: localenv.sh [\e[0m\e[32mup\e[0m\e[32m|\e[0m\e[32mdown\e[0m\e[32m|\e[0m\e[32mpytest\e[0m\e[32m|\e[0m\e[32mdebug\e[0m\e[32m|\e[0m\e[32mipython\e[0m\e[32m|\e[0m\e[32mlint\e[0m\e[32m|\e[0m\e[32minstall\e[0m\e[32m]\e[0m"
    echo -e "\e[32m  up:\e[0m start the local environment"
    echo -e "\e[32m  down:\e[0m stop the local environment"
    echo -e "\e[32m  pytest:\e[0m run pytest in the container. It accepts all the pytest arguments. Needs 'devops-docker' project running\e[0m"
    echo -e "\e[32m  debug:\e[0m starts gunicorn in a verbose mode to debug possible startup errors\e[0m" 
    echo -e "\e[32m  ipython:\e[0m starts ipython shell with the database connection\e[0m"
    echo -e "\e[32m  lint:\e[0m run black to lint the code\e[0m"
    echo -e "\e[32m  install:\e[0m install project from scratch (create virtualenv, etc.)\e[0m"
fi
