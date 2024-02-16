#!/bin/bash

function recreate_venv() {
  if [ -d "venv" ]; then
    echo "Removing old ./venv virtual environment"
    rm -rf ./venv
  fi
  echo "Creating new virtual environment at ./venv"
  pyenv local $required_version
  python -m venv venv
  source ./venv/bin/activate
  pip3 install --upgrade pip
  pip3 install poetry
}

function install_dev_requirements() {
  pip3 install pytest && \
  pip3 install hypercorn && \
  pip3 install pytest-mock && \
  pip3 install pytest-cov
}

function install_precommit_hooks() {
  pip3 install pre-commit
  echo "Installing pre-commit hooks"
  pre-commit install
}

function install_requirements_on_docker() {
  echo "Installing requirements.txt"
  pip3 install -r /requirements.txt
}

function install_requirements_on_local() {
  activate_venv
  poetry config virtualenvs.create false
  poetry export -f requirements.txt --output requirements.txt
  pip3 install -r requirements.txt
}

function activate_venv() {
   source ./venv/bin/activate
}


required_version="$1"
python_interpreter="python$required_version"

# Check if the required version is installed
if ! command -v $python_interpreter &> /dev/null; then
    echo "Error: Python $required_version is not installed."
    exit 1
fi

echo "Python version set is $python_interpreter. Continuing with the script..."
echo "Upgrading pip"
pip3 install --upgrade pip

# Difference between docker and local, is that docker doesn't use venv
if [[ "$1" == "docker" ]]; then
  echo "Installing requirements on docker"
  install_dev_requirements
  install_requirements_on_docker
else
  recreate_venv
  echo "Installing dev/local dependencies"
  activate_venv
  install_dev_requirements
  install_precommit_hooks
  install_requirements_on_local
fi

echo "Done!"
