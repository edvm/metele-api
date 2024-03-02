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
  sed -e "s/\$PORT/$API_PORT/g" ./scripts/files/dev.dockerfile > ./dockerfiles/dev.dockerfile
  echo -e "\033[1mdev.dockerfile\033[0m file created."
}

function generate_env_file() {
  echo -e "PROJECT_NAME=\"$PROJECT_NAME\"\nPROJECT_DESCRIPTION=\"$PROJECT_DESCRIPTION\"\nPROJECT_AUTHOR_NAME=\"$PROJECT_AUTHOR_NAME\"\nPROJECT_AUTHOR_EMAIL=\"$PROJECT_AUTHOR_EMAIL\"\nAPI_HOST=\"$API_HOST\"\nAPI_PORT=\"$API_PORT\"" > .env
  echo -e "\033[1m.env\033[0m file created."
}

function create_files() {

  read_metele_api_config_file
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

  # Check if `docker compose` is installed, if not, echo a message and exit the script
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

# Check if .metele file exists and echo a message to the user
if ! metele_api_config_file_exists; then
  echo -e "Before proceeding, you must create a \033[1m.metele\033[0m file with the project settings."
  echo -e "You can use the provided \033[1mmetele.example\033[0m file as a template.\n"
  exit 1
fi

# Echo a message to the user telling that `docker` and `docker compose` are required
echo -e "This script requires \033[1mdocker, curl\033[0m and \033[1mdocker compose\033[0m to be installed in your system.\n"

# Write a brief description of the steps this installer will take
echo -e "This script will execute the following steps:\n"

echo -e "- \033[1mCreate these files\033[0m:"
echo -e "\t- pyproject.toml" 
echo -e "\t- docker-compose.yml"
echo -e "\t- dev.dockerfile"
echo -e "\t- .env"

if ! rye_installed; then
  echo -e "\n- \033[1mInstall Rye\033[0m:"
  echo -e "\tIt will check if its already installed. If not, it will install it."
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

# Check that .metele file exists 
if ! metele_api_config_file_exists; then
  echo "You must create a .metele file, use provided 'metele.example' file as a template."
  exit 1
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
