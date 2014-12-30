PACKAGE = docker
BUILD_DIR = /tmp/$(PACKAGE)-build
RELEASE_DIR = /tmp/$(PACKAGE)-release
RELEASE_FILE = /tmp/$(PACKAGE).tar.gz

PACKAGE_VERSION = $$(awk -F= '/^version/ {print $$2}' upstream/package/info)
PATCH_VERSION = $$(cat version)
VERSION = $(PACKAGE_VERSION)-$(PATCH_VERSION)
CONF_FLAGS = --enable-static --enable-ipv6 --disable-slashpackage --enable-monotonic

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
	cd $(BUILD_DIR) && CC="musl-gcc" ./configure --prefix=$(RELEASE_DIR) $(CONF_FLAGS)
	make -C $(BUILD_DIR)
	make -C $(BUILD_DIR) install
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

