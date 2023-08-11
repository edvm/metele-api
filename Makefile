SHELL := /bin/bash

# Variables definitions
# -----------------------------------------------------------------------------

ifeq ($(TIMEOUT),)
TIMEOUT := 60
endif

# Target section and Global definitions
# -----------------------------------------------------------------------------
.PHONY: all clean dev help

all: clean dev help

define HEADER

    ______           __               ______           __        ___    ____  ____
   / ____/___ ______/ /____  _____   / ____/___ ______/ /_      /   |  / __ \/  _/
  / /_  / __ `/ ___/ __/ _ \/ ___/  / /_  / __ `/ ___/ __/_____/ /| | / /_/ // /  
 / __/ / /_/ (__  ) /_/  __/ /     / __/ / /_/ (__  ) /_/_____/ ___ |/ ____// /   
/_/    \__,_/____/\__/\___/_/     /_/    \__,_/____/\__/     /_/  |_/_/   /___/   
                                                                                 
             An opinionated template for Python projects using Fast-API. 


endef
export HEADER

help:
	clear
	@echo "$$HEADER"
	@echo "Usage: make [target]"
	@echo "  dev - Run dev server."
	@echo ""
	@echo "In order to run tests:"
	docker exec -it api poetry install --with dev
	docker exec -it api poetry run pytest --cov=app tests/unit -vv --show-capture=all --cov-report term-missing

dev:
	docker build .
	docker compose -f docker-compose-dev.yml up api

clean:
	@echo Setting .env file with default values
	cp -v .env.example .env

	@echo Removing virtual environment
	rm -rf ./venv

	@echo Cleaning poetry cache
	poetry cache clear pypi --all

	@echo Remove all containers
	docker-compose -f docker-compose-dev.yml down --remove-orphans

	@echo Remove temporary files
	@find . -name '*.pyc' -exec rm -rf {} \;
	@find . -name '__pycache__' -exec rm -rf {} \;
	@find . -name 'Thumbs.db' -exec rm -rf {} \;
	@find . -name '*~' -exec rm -rf {} \;
	rm -rf .cache
	rm -rf build
	rm -rf dist
	rm -rf *.egg-info
	rm -rf htmlcov
	rm -rf .tox/
	rm -rf docs/_build
