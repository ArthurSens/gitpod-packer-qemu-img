PACKER_CACHE_DIR=$(PWD)

.PHONY: prepare-workspace
prepare-workspace:
	./prepare-environment.sh

.PHONY: build-base
build-base: prepare-workspace
	packer build \
	-var packer_cache_dir=${PACKER_CACHE_DIR} \
	base-qemu.pkr.hcl