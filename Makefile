.PHONY: help

VERSION ?= `grep 'version' mix.exs | sed -e 's/ //g' -e 's/version://' -e 's/[",]//g'`
IMAGE_NAME ?= distillery_example
PWD ?= `pwd`

help:
	@echo "$(IMAGE_NAME):$(VERSION)"
	@perl -nle'print $& if m{^[a-zA-Z_-]+:.*?## .*$$}' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

init: ## Initialize the project from a clean state
	mix local.rebar --force
	mix local.hex --force
	mix deps.get

compile: ## Build the application
	mix do compile, phx.digest

clean: ## Clean up generated artifacts
	mix clean

rebuild: clean build ## Rebuild the application

image: ## Mimic CodeBuild build
	docker run --rm -e BUILD_DIR=/opt/app -v $(PWD):/opt/app -it centos:7 /opt/app/bin/build all

release: ## Build a release of the application with MIX_ENV=prod
	MIX_ENV=prod mix do deps.get, compile
	MIX_ENV=prod mix phx.digest
	MIX_ENV=prod mix release --verbose
	@cp _build/prod/rel/$(IMAGE_NAME)/releases/$(VERSION)/$(IMAGE_NAME).tar.gz $(IMAGE_NAME).tar.gz
