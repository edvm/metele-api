#!/usr/bin/env bash

cu

function rye_installed() {
  if [ -f "$HOME/.rye/env" ]; then
    return 0
  else
    return 1
  fi
} 

function ask_project_settings() {
  echo -e "\nPlease provide the following information to create a \033[1m.env\033[0m file with the following variables:\n"
  echo -e "- \033[1mPROJECT_NAME\033[0m: The name of the project."
  read -p "  Project name: " project_name
  echo -e "- \033[1mPROJECT_DESCRIPTION\033[0m: A brief description of the project."
  read -p "  Project description: " project_description
  echo -e "- \033[1mPROJECT_AUTHOR_NAME\033[0m: The name of the author of the project."
  read -p "  Project author name: " project_author_name
  echo -e "- \033[1mPROJECT_AUTHOR_EMAIL\033[0m: The email of the author of the project."
  read -p "  Project author email: " project_author_email
  echo -e "- \033[1mAPI_HOST\033[0m: The host where the API will listen."
  read -p "  API host: " api_host
  echo -e "- \033[1mAPI_PORT\033[0m: The port where the API will listen."
  read -p "  API port: " api_port
  echo -e "- \033[1mPYTHON_VERSION\033[0m: The version of Python to use. It'll be installed using Rye (if not already installed in your system)"
  read -p "  Python version (i.e: 3.12): " python_version

  # Make the python version be available to the rest of the script
  export PYTHON_VERSION=$python_version 

  # Copy the file ./scripts/files/pyproject.sample.toml to pyproject.toml
  # Replace the following variables in the file:
  sed -e "s/\$NAME/$project_name/g" -e "s/\$DESCRIPTION/$project_description/g" -e "s/\$AUTHOR_NAME/$project_author_name/g" -e "s/\$AUTHOR_EMAIL/$project_author_email/g" -e "s/\$PYTHON_VERSION/$python_version/g" ./scripts/files/pyproject.sample.toml > pyproject.toml
  echo -e "\n\033[1mpyproject.toml\033[0m file created."

  # Create the .env file with the provided variables
  echo -e "PROJECT_NAME=\"$project_name\"\nPROJECT_DESCRIPTION=\"$project_description\"\nPROJECT_AUTHOR_NAME=\"$project_author_name\"\nPROJECT_AUTHOR_EMAIL=\"$project_author_email\"\nAPI_HOST=\"$api_host\"\nAPI_PORT=\"$api_port\"" > .env
  echo -e "\033[1m.env\033[0m file created."

  echo -e "\nDo you want to proceed with the installation? (\033[1my/n\033[0m)"
  read install_proceed
  if [ "$install_proceed" != "y" ]; then
    echo "Exiting..."
    exit 1
  fi
}

function check_dependencies() {
  # Check if `docker` is installed, if not, echo a message and exit the script
  if ! command -v docker &> /dev/null; then
    echo "Docker is not installed. Please install it and try again."
    exit 1
  fi

  # Check if `docker-compose` is installed, if not, echo a message and exit the script
  if ! command -v docker compose &> /dev/null; then
    echo "Docker Compose is not installed. Please install it and try again."
    exit 1
  fi
}

function install_rye() {

  if rye_installed; then
    echo -e "\033[1mRye\033[0m is already installed."
    return
  fi

  if ! command -v rye &> /dev/null; then
    curl -sSf https://rye-up.com/get | bash
  fi
}

function install_dependencies_with_rye() {
  source "$HOME/.rye/env"

  # Be sure to have the python version installed
  rye fetch $PYTHON_VERSION
  rye pin $PYTHON_VERSION

  rye sync
  rye add fastapi pydantic-settings httpx loguru hypercorn result 
  rye add --dev pytest pytest-mock pytest-cov pre-commit mkdocs-material mkdocs-material[imaging] 
  rye sync
}

clear

# Write in bold "Welcome to MeteleAPI installation script"
echo -e "\033[1mWelcome to MeteleAPI installation script\033[0m"
echo -e "----------------------------------------\n"

# Echo a message to the user telling that `docker` and `docker-compose` are required
echo -e "This script requires \033[1mDocker, Curl\033[0m and \033[1mDocker Compose\033[0m to be installed in your system.\n"

# Write a brief description of the steps this installer will take
echo -e "This script will execute the following steps:\n"

echo -e "- It will ask you for some information to create an \033[1m.env\033[0m file with the following variables:\n"
echo -e "\t- \033[1mPROJECT_NAME\033[0m: The name of the project."
echo -e "\t- \033[1mPROJECT_DESCRIPTION\033[0m: A brief description of the project."
echo -e "\t- \033[1mPROJECT_AUTHOR_NAME\033[0m: The name of the author of the project."
echo -e "\t- \033[1mPROJECT_AUTHOR_EMAIL\033[0m: The email of the author of the project."
echo -e "\t- \033[1mAPI_HOST\033[0m: The host where the API will listen."
echo -e "\t- \033[1mAPI_PORT\033[0m: The port where the API will listen."
echo -e "\t- \033[1mPYTHON_VERSION\033[0m: The version of Python to use. Will be installed using Rye, no worries if its not installed in your system."
echo -e ""

if ! rye_installed; then
  echo -e "- \033[1mRye\033[0m:\tIt will check if its already installed. If not, it will install it."
  echo -e "\tIt provides a unified experience to \033[1minstall and manages Python installations.\033[0m \n\tIf you want to know more about \033[1mRye\033[0m, please visit https://rye-up.com/."
fi

# if ! rye_installed; then
#   echo -e "- \033[1mRye\033[0m:\tIt will check if its already installed. If not, it will install it."
#   echo -e "\tIt provides a unified experience to \033[1minstall and manages Python installations.\033[0m \n\tIf you want to know more about \033[1mRye\033[0m, please visit https://rye-up.com/."
# fi
echo -e "\n"

# Ask user if it wants to proceed
echo -e "Do you want to proceed? (\033[1my/n\033[0m)"
read install_proceed
if [ "$install_proceed" != "y" ]; then
  echo "Exiting..."
  exit 1
fi

# Check dependencies are installed 
check_dependencies

# Ask user for project settings
ask_project_settings

# Check if 'rye' is installed, if not, install it
install_rye

# Check if 'rye' is installed, if not, quit the script
if ! rye_installed; then
  echo "Rye is not installed. Please install it and try again."
  exit 1
fi 

install_dependencies_with_rye


echo -e "\n\033[1mAll dependencies installed successfully!\033[0m"
echo -e "----------------------------------------\n"
echo -e "Open a new terminal or run \033[1m source ~/.rye/env\033[0m.\n"
echo -e "Type \033[1mpython\033[0m and you'll get a Python interpreter running the version you selected: $PYTHON_VERSION.\n"
