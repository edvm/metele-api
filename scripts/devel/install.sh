#!/usr/bin/env bash

function install_rye() {
  # Check if `rye` is installed, if not, install it
  if ! command -v rye &> /dev/null; then
    curl -sSf https://rye-up.com/get | bash
  fi
  source "$HOME/.rye/env"
}

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

function install_requirements_on_local() {
  activate_venv
  pip3 install -r dev-requirements.txt
}

function activate_venv() {
   source ./venv/bin/activate
}


# required_version="$1"
# python_interpreter="python$required_version"


# # Check if the required version is installed
# if ! command -v $python_interpreter &> /dev/null; then
#     echo "Error: Python $required_version is not installed."
#     exit 1
# fi

# echo "Python version set is $python_interpreter. Continuing with the script..."
# echo "Upgrading pip"
# pip3 install --upgrade pip

# recreate_venv
# echo "Installing dev/local dependencies"
# activate_venv
# install_dev_requirements
# install_requirements_on_local

# Clear all the previous text in the terminal
clear

# Write in bold "Welcome to MeteleAPI installation script"
echo -e "\033[1mWelcome to MeteleAPI installation script\033[0m"
echo -e "----------------------------------------\n"

# Write a brief description of the steps this installer will take
echo -e "This script will execute the following steps:\n"

if ! command -v rye &> /dev/null; then
  echo -e "- \033[1mRye\033[0m:\tIt will check if its already installed. If not, it will install it."
  echo -e "\tIt provides a unified experience to \033[1minstall and manages Python installations.\033[0m \n\tIf you want to know more about \033[1mRye\033[0m, please visit https://rye-up.com/."
fi
echo -e "\n"

# Ask user if it wants to proceed
echo -e "Do you want to proceed? (\033[1my/n\033[0m)"
read install_proceed
if [ "$install_proceed" != "y" ]; then
  echo "Exiting..."
  exit 1
fi

# Check if `rye` is installed, if not, install it
install_rye

# Ask user if it wants to install pre-commit hooks
# echo "Do you want to install pre-commit hooks? (y/n)"
# read install_precommit
# if [ "$install_precommit" == "y" ]; then
#   install_precommit_hooks
# fi


echo "Done!"