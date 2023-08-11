#!/bin/bash

function recreate_venv() {
  if [ -d "venv" ]; then
    echo "Removing old ./venv virtual environment"
    rm -rf ./venv
  fi
  echo "Creating new virtual environment at ./venv"
  python3 -m venv venv
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


required_version="3.11.0"
current_version=$(python3 -c "import sys; print('.'.join(map(str, sys.version_info[:3])))")

if [[ "$current_version" < "$required_version" ]]; then
    echo "Error: Python >= version $required_version is required, but found $current_version"
    exit 1
fi


echo "Python version is $required_version. Continuing with the script..."


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
