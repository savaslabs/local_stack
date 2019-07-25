# ----------------
# Make help script
# ----------------

# Usage:
# Add help text after target name starting with '\#\#'
# A category can be added with @category. Team defaults:
# 	dev-environment
# 	docker
# 	drush

# Output colors
GREEN  := $(shell tput -Txterm setaf 2)
WHITE  := $(shell tput -Txterm setaf 7)
YELLOW := $(shell tput -Txterm setaf 3)
RESET  := $(shell tput -Txterm sgr0)

# Detect OS

OS_NAME := $(shell uname -s | tr A-Z a-z)

# Script
HELP_FUN = \
	%help; \
	while(<>) { push @{$$help{$$2 // 'options'}}, [$$1, $$3] if /^([a-zA-Z\-]+)\s*:.*\#\#(?:@([a-zA-Z\-]+))?\s(.*)$$/ }; \
	print "usage: make [target]\n\n"; \
	print "see makefile for additional commands\n\n"; \
	for (sort keys %help) { \
	print "${WHITE}$$_:${RESET}\n"; \
	for (@{$$help{$$_}}) { \
	$$sep = " " x (32 - length $$_->[0]); \
	print "  ${YELLOW}$$_->[0]${RESET}$$sep${GREEN}$$_->[1]${RESET}\n"; \
	}; \
	print "\n"; }

help: ## Show help (same if no target is specified).
	@perl -e '$(HELP_FUN)' $(MAKEFILE_LIST) $(filter-out $@,$(MAKECMDGOALS))

#
# Dev Environment settings
#

include .env

.PHONY: up down stop prune ps shell drush logs help

default: up

PROJECT_ROOT ?= /var/www/html
DRUPAL_ROOT ?= /var/www/html/docroot

#
# Dev Operations
#
up: ##@docker Start containers and display status.
	@echo "Starting up containers for $(PROJECT_NAME)..."
	docker-compose pull
	make docker-up
	docker-compose ps

docker-up:
    ifeq ($(OS_NAME),linux)
	    docker-compose up -d --remove-orphans
    endif
    ifeq ($(OS_NAME),darwin)
	    # Override default config with MacOS specific config.
	    docker-compose -f docker-compose.yml -f docker-compose.macOS.yml up -d --remove-orphans
    endif

down: stop

stop: ##@docker Stop and remove containers.
	@echo "Stopping containers for $(PROJECT_NAME)..."
	@docker-compose stop

clean: ##@docker Remove containers and other files created during install.
	make prune
	rm .env
	rm docroot/sites/default/settings.local.php

prune: ##@docker Remove containers for project.
	@echo "Removing containers for $(PROJECT_NAME)..."
	@docker-compose down -v

ps: ##@docker List containers.
	@docker ps --filter name='$(PROJECT_NAME)*'

shell: ##@docker Shell into the container. Specify container name.
	docker exec -ti -e COLUMNS=$(shell tput cols) -e LINES=$(shell tput lines) $(shell docker ps --filter name='$(PROJECT_NAME)_php' --format "{{ .ID }}") sh

shell-mysql: ##@docker Shell into mysql container.
	docker exec -ti -e COLUMNS=$(shell tput cols) -e LINES=$(shell tput lines) $(shell docker ps --filter name='$(PROJECT_NAME)_mariadb' --format "{{ .ID }}") sh

drush: ##@docker Run arbitrary drush commands.
	docker exec $(shell docker ps --filter name='$(PROJECT_NAME)_php' --format "{{ .ID }}") drush -r $(DRUPAL_ROOT) $(filter-out $@,$(MAKECMDGOALS))

logs: ##@docker Display log.
	@docker-compose logs -f $(filter-out $@,$(MAKECMDGOALS))

#
# Dev Environment build operations
#
install: ##@dev-environment Configure development environment.
	if [ ! -f .env ]; then cp .env.dist .env; fi
	make down
	make up
	echo "Giving Docker a few seconds..."; sleep 10
	make composer-install
	chmod 777 docroot/sites/default
	if [ ! -f docroot/sites/default/settings.local.php ]; then cp .docker/drupal/settings.local.php docroot/sites/default/settings.local.php; fi
	git config core.hooksPath .git/hooks
	@echo "Pulling database for $(PROJECT_NAME)..."
	make pull-db
	make pull-files
	make prep-site

travis-install: ##@dev-environment Configure development environment - Travis build.
	if [ ! -f .env ]; then cp .env.dist .env; fi
	make down
	make up
	echo "Giving Docker a few seconds..."; sleep 10
	# Configure phpcs to use Drupal coding standards (this typically runs as a post `composer install` script).
	vendor/bin/phpcs --config-set installed_paths vendor/drupal/coder/coder_sniffer

composer-update: ##@dev-environment Run composer update.
	docker-compose exec -T php composer update -n --prefer-dist -v

composer-install: ##@dev-environment Run composer install
	docker-compose exec -T php composer install -n --prefer-dist -v

import-db: ##@dev-environment Import locally cached copy of `database.sql` to project dir.
	@echo "Dropping old database for $(PROJECT_NAME)..."
	docker exec $(shell docker ps --filter name='$(PROJECT_NAME)_php' --format "{{ .ID }}") drush -r $(DRUPAL_ROOT) sql-drop -v
	@echo "Importing database for $(PROJECT_NAME)..."
	pv .docker/db/import/database.sql | docker exec -i dardenmain_mariadb mysql -udrupal -pdrupal drupal
	make drush cr
	make sanitize-db

export-db:
	docker exec $(shell docker ps --filter name='$(PROJECT_NAME)_php' --format "{{ .ID }}") drush -r $(DRUPAL_ROOT) sql:dump --result-file=$(PROJECT_ROOT)/.docker/db/export/database.sql --gzip --structure-tables-key=common

pull-db: ##@dev-environment Download AND import `database.sql`.
	if [ -f .docker/db/import/database.sql.gz ]; then rm .docker/db/import/database.sql.gz; fi
	if [ -f .docker/db/import/database.sql ]; then rm .docker/db/import/database.sql; fi
	@echo "Pulling DB from Acquia"
	drush @self.prod sql-dump > .docker/db/import/database.sql -q
	make import-db

pull-files: ##@dev-environment Pull files from production site.
	drush rsync @self.prod:/var/www/html/dardenexternal.prod/docroot/sites/default/files @self.local:./sites/default -y

sanitize-db: ##@dev-environment Sanitize the database.
	# Sanitize database.
	@echo "Sanitizing database for $(PROJECT_NAME)..."
	docker exec $(shell docker ps --filter name='$(PROJECT_NAME)_php' --format "{{ .ID }}") drush -r $(DRUPAL_ROOT) sqlsan
	# Set admin user password to "password".
	@echo "Admin password is set to 'password'"
	docker exec $(shell docker ps --filter name='$(PROJECT_NAME)_php' --format "{{ .ID }}") drush -r $(DRUPAL_ROOT) user:password admin "password"

prep-site: ##@dev-environment Prepare site for local dev.
	make install-theme-dependencies
	make sanitize-db
	make updb
	make cim
	make enable-dev-modules
	make uli

#
# Drush
#
cr: ##drush Rebuild Drupal cache.
	docker exec $(shell docker ps --filter name='$(PROJECT_NAME)_php' --format "{{ .ID }}") drush -r $(DRUPAL_ROOT) cr

uli: ##drush Generate login link.
	docker exec $(shell docker ps --filter name='$(PROJECT_NAME)_php' --format "{{ .ID }}") drush -r $(DRUPAL_ROOT) uli -l $(shell echo $(PROJECT_BASE_URL))

cim: ##drush Drush import configuration.
	docker exec $(shell docker ps --filter name='$(PROJECT_NAME)_php' --format "{{ .ID }}") drush -r $(DRUPAL_ROOT) config-import

cex: ##drush Drush export configuration.
	docker exec $(shell docker ps --filter name='$(PROJECT_NAME)_php' --format "{{ .ID }}") drush -r $(DRUPAL_ROOT) config-export

updb: ##drush run database updates.
	docker exec $(shell docker ps --filter name='$(PROJECT_NAME)_php' --format "{{ .ID }}") drush -r $(DRUPAL_ROOT) updb -v

enable-dev-modules: ##drush Enable modules for local development.
	docker exec $(shell docker ps --filter name='$(PROJECT_NAME)_php' --format "{{ .ID }}") drush -r $(DRUPAL_ROOT) en devel kint views_ui field_ui dblog -y

#
# Theme commands
#
install-theme-dependencies: ##theme Installs npm dependencies for custom theme.
	cd docroot/themes/custom/darden_main && npm install

build-theme-files: ##theme Builds CSS and JS bundle files for production.
	cd docroot/themes/custom/darden_main && npm run build

#
# Tests
#
phpcs:
	docker exec $(shell docker ps --filter name='$(PROJECT_NAME)_php' --format "{{ .ID }}") vendor/bin/phpcs --standard=Drupal docroot/modules/custom docroot/themes/custom/darden_main --ignore=*.css,*scss,*.js,*.min.js,*.md,*.txt,node_modules/* --exclude=Drupal.InfoFiles.AutoAddedKeys


# https://stackoverflow.com/a/6273809/1826109
%:
	@: