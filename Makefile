PACKAGE = docker
RELEASE_DIR = /tmp/$(PACKAGE)-release
RELEASE_FILE = /tmp/$(PACKAGE).tar.gz

PACKAGE_VERSION = $$(cat upstream/VERSION)
PATCH_VERSION = $$(cat version)
VERSION = $(PACKAGE_VERSION)-$(PATCH_VERSION)

.PHONY : default manual container version build push local

default: upstream container

upstream:
	git clone git://github.com/docker/docker upstream

manual:
	./meta/launch /bin/bash || true

container:
	./meta/launch

build:
	make -C upstream binary
	rm -rf $(RELEASE_DIR)
	mkdir -p $(RELEASE_DIR)/usr/bin
	cp upstream/bundles/$(PACKAGE_VERSION)/binary/docker-$(PACKAGE_VERSION) $(RELEASE_DIR)/usr/bin/docker
	cd $(RELEASE_DIR) && tar -czvf $(RELEASE_FILE) *

version:
	@echo $$(($(PATCH_VERSION) + 1)) > version

push: version
	git commit -am "$(VERSION)"
	ssh -oStrictHostKeyChecking=no git@github.com &>/dev/null || true
	git tag -f "$(VERSION)"
	git push --tags origin master
	targit -a .github -c -f dock0/docker-pkg $(VERSION) $(RELEASE_FILE)

local: build push

