#!/usr/bin/env bash

cu

function rye_installed() {
  if [ -f "$HOME/.rye/env" ]; then
    return 0
  else
    return 1
  fi
} 

function metele_api_config_file_exists() {
  if [ -f ".metele" ]; then
    return 0
  else
    return 1
  fi
}

function read_metele_api_config_file() {
  if metele_api_config_file_exists; then
    source .metele
  fi
}

function ask_project_settings() {
  echo -e "\nPlease provide the following information to create a \033[1m.env\033[0m file with the following variables:\n"
  echo -e "- \033[1mPROJECT_NAME\033[0m: The name of the project (better if its lowercase)."
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
  echo -e "- \033[1mPYTHON_VERSION\033[0m: The version of Python to use. It'll be installed using Rye (if not already installed in your system). Just provide the version number (e.g. 3.12)."
  read -p "  Python version: " python_version

  export PYTHON_VERSION=$python_version
  export API_HOST=$api_host
  export API_PORT=$api_port
  export PROJECT_NAME=$project_name
  export PROJECT_DESCRIPTION=$project_description
  export PROJECT_AUTHOR_NAME=$project_author_name
  export PROJECT_AUTHOR_EMAIL=$project_author_email
}

function generate_pyproject_toml() {
  sed -e "s/\$NAME/$PROJECT_NAME/g" -e "s/\$DESCRIPTION/$PROJECT_DESCRIPTION/g" -e "s/\$AUTHOR_NAME/$PROJECT_AUTHOR_NAME/g" -e "s/\$AUTHOR_EMAIL/$PROJECT_AUTHOR_EMAIL/g" -e "s/\$PYTHON_VERSION/$PYTHON_VERSION/g" ./scripts/files/pyproject.sample.toml > pyproject.toml
  echo -e "\n\033[1mpyproject.toml\033[0m file created."
}

function generate_docker_compose() {
  sed -e "s/\$PORT/$API_PORT/g" -e "s/\$PROJECT_NAME/$PROJECT_NAME/g" -e "s/\$HOST/$API_HOST/g" ./scripts/files/docker-compose.sample.yml > docker-compose.yml
  echo -e "\033[1mdocker-compose.yml\033[0m file created."
}

function generate_dev_dockerfile() {
  mkdir -p dockerfiles
  sed -e "s/\$PORT/$API_PORT/g" ./scripts/files/dev.dockerfile > dev.dockerfile
  echo -e "\033[1mdev.dockerfile\033[0m file created."
}

function generate_env_file() {
  echo -e "PROJECT_NAME=\"$PROJECT_NAME\"\nPROJECT_DESCRIPTION=\"$PROJECT_DESCRIPTION\"\nPROJECT_AUTHOR_NAME=\"$PROJECT_AUTHOR_NAME\"\nPROJECT_AUTHOR_EMAIL=\"$PROJECT_AUTHOR_EMAIL\"\nAPI_HOST=\"$API_HOST\"\nAPI_PORT=\"$API_PORT\"" > .env
  echo -e "\033[1m.env\033[0m file created."
}

function create_files() {

  if metele_api_config_file_exists; then
    read_metele_api_config_file
  else
    ask_project_settings
  fi

  generate_pyproject_toml
  generate_docker_compose
  generate_dev_dockerfile
  generate_env_file

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
echo -e "This script requires \033[1mdocker, curl\033[0m and \033[1mdocker compose\033[0m to be installed in your system.\n"

# Write a brief description of the steps this installer will take
echo -e "This script will execute the following steps:\n"

echo -e "- \033[1mDependencies\033[0m:\tIt will check if \033[1mdocker\033[0m and \033[1mdocker-compose\033[0m are installed."

if ! metele_api_config_file_exists; then
  echo -e "- It will ask you for some information to create the following files:\n"
  echo -e "\t- \033[1mpyproject.toml\033[0m: A file with the project's metadata."
  echo -e "\t- \033[1mdocker-compose.yml\033[0m: A file with the configuration to run the API with Docker."
  echo -e "\t- \033[1mdev.dockerfile\033[0m: A file with the configuration to run the API with Docker in development mode."
  echo -e "\t- \033[1m.env\033[0m: A file with the environment variables for the project."
else
  echo -e "- \033[1mSettings\033[0m:\tIt will read the \033[1m.metele\033[0m file to get the project settings."
fi

if ! rye_installed; then
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

# Check dependencies are installed 
check_dependencies

# Ask user for project settings
if ! metele_api_config_file_exists; then
  ask_project_settings
fi
create_files

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
