# Extract metadata from Makefile
PKG_NAME := $(shell grep '^PKG_NAME:=' Makefile | cut -d= -f2)
PKG_DEPENDS := $(shell grep '^\s*DEPENDS:=' Makefile | cut -d= -f2 | tr -d '+')

# Development Environment Configuration
SDK_VERSION := 24.10.5
SDK_ARCH := x86-64
BUILDER_IMAGE := $(PKG_NAME)-builder:$(SDK_ARCH)-$(SDK_VERSION)
RUNNER_IMAGE := $(PKG_NAME)-tester:$(SDK_ARCH)-$(SDK_VERSION)

WORK_DIR := $(shell pwd)

.PHONY: all prepare test watch-tests package clean

all: test

prepare:
	echo "Building development container for $(SDK_ARCH)-$(SDK_VERSION)..."
	docker build -t $(RUNNER_IMAGE) \
		--build-arg SDK_ARCH=$(SDK_ARCH) \
		--build-arg SDK_VERSION=$(SDK_VERSION) \
		--build-arg PKG_DEPENDS="$(sort $(PKG_DEPENDS))" \
		-f Dockerfile.dev .
	echo "Building packaging container for $(SDK_ARCH)-$(SDK_VERSION)..."
	docker build -t $(BUILDER_IMAGE) \
		--build-arg SDK_ARCH=$(SDK_ARCH) \
		--build-arg SDK_VERSION=$(SDK_VERSION) \
		-f Dockerfile .
	$(MAKE) -f dev.mk sync-headers

sync-headers:
	@echo "Syncing headers from $(BUILDER_IMAGE)..."
	@mkdir -p .include
	@docker run --rm -v "$(WORK_DIR)/.include:/host_include" $(BUILDER_IMAGE) \
		sh -c "cp -r /sdk/staging_dir/target-*/usr/include/* /host_include/"
	@echo "Headers synced to .include/"

test: compile-native
	@docker run --rm \
		-v "$(WORK_DIR):/app" \
		-e VERBOSE=$(VERBOSE) \
		$(RUNNER_IMAGE) \
		ucode -L /app/bin/lib -L /app/files/usr/share/ucode -L /app/test test/runner.uc

SOURCES := $(wildcard src/*.c)

# Sentinel file to track build status
bin/lib/.built: $(SOURCES) src/CMakeLists.txt
	@echo "Source changed, compiling C extension(s) in SDK..."
	@mkdir -p bin/lib
	@chmod 777 bin/lib
	@if docker run --rm \
		-v "$(WORK_DIR):/sdk/package/$(PKG_NAME)" \
		-v "$(WORK_DIR)/bin/lib:/artifacts" \
		$(BUILDER_IMAGE) \
		sh -c "make package/$(PKG_NAME)/compile V=s >/dev/null && \
		       for f in package/$(PKG_NAME)/src/*.c; do \
		           [ -f \"\$$f\" ] || continue; \
		           name=\$$(basename \$$f .c); \
		           find build_dir -path \"*/usr/lib/ucode/\$$name.so\" -exec cp {} /artifacts/ \;; \
		       done"; then \
		touch bin/lib/.built; \
	else \
		echo "Build failed!"; exit 1; \
	fi

compile-native: bin/lib/.built

debug: compile-native
	@echo "Starting debug shell..."
	@docker run --rm -it \
		-v "$(WORK_DIR):/app" \
		-e VERBOSE=$(VERBOSE) \
		$(RUNNER_IMAGE) \
		/bin/sh

watch-tests:
	@echo "Watching for changes using entr..."
	@find src test files -type f 2>/dev/null | entr -c -r $(MAKE) -f dev.mk test

package:
	@mkdir -p bin
	@chmod 777 bin
	@echo "Building IPK for $(SDK_ARCH) using $(BUILDER_IMAGE)..."
	docker run --rm \
		-v "$(WORK_DIR):/sdk/package/$(PKG_NAME)" \
		-v "$(WORK_DIR)/bin:/sdk/bin" \
		$(BUILDER_IMAGE) \
		sh -c "make defconfig && make package/$(PKG_NAME)/compile V=s"
	@echo "Package build complete. Check the 'bin' directory for the .ipk file."

clean:
	@rm -rf bin/
