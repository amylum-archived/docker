PACKAGE = docker
ORG = amylum
BUILD_DIR = /tmp/$(PACKAGE)-build
RELEASE_DIR = /tmp/$(PACKAGE)-release
RELEASE_FILE = /tmp/$(PACKAGE).tar.gz

PACKAGE_VERSION = $$(cat upstream/VERSION)
PATCH_VERSION = $$(cat version)
VERSION = $(PACKAGE_VERSION)-$(PATCH_VERSION)

.PHONY : default manual container version build push local

default: upstream/Makefile container

upstream/Makefile:
	git submodule update --init

manual:
	./meta/launch /bin/bash || true

container:
	./meta/launch

build:
	rm -rf $(BUILD_DIR)
	cp -R upstream $(BUILD_DIR)
	make -C $(BUILD_DIR) binary
	rm -rf $(RELEASE_DIR)
	mkdir -p $(RELEASE_DIR)/usr/bin $(RELEASE_DIR)/usr/share/licenses/$(PACKAGE)
	cp upstream/bundles/$(PACKAGE_VERSION)/binary/docker-$(PACKAGE_VERSION) $(RELEASE_DIR)/usr/bin/docker
	cp upstream/LICENSE $(RELEASE_DIR)/usr/share/licenses/$(PACKAGE)/LICENSE
	cd $(RELEASE_DIR) && tar -czvf $(RELEASE_FILE) *

version:
	@echo $$(($(PATCH_VERSION) + 1)) > version

push: version
	git commit -am "$(VERSION)"
	ssh -oStrictHostKeyChecking=no git@github.com &>/dev/null || true
	git tag -f "$(VERSION)"
	git push --tags origin master
	targit -a .github -c -f $(ORG)/$(PACKAGE) $(VERSION) $(RELEASE_FILE)

local: build push

