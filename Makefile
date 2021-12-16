PACKER_CACHE_DIR=$(PWD)

.PHONY: build-base
build-base:
	packer build \
	-var packer_cache_dir=${PACKER_CACHE_DIR} \
	base-qemu.pkr.hcl