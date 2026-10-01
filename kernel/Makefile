export ARCH = riscv
export CROSS_COMPILE = riscv64-linux-gnu-

LINUX_SOURCE_DIR = "linux-mainline"
LINUX_BUILD_DIR = "linux-mainline-build"
OUT_DIR = "out"


init:
	cd $(LINUX_SOURCE_DIR) && make O=../$(LINUX_BUILD_DIR) defconfig
menuconfig:
	cd $(LINUX_BUILD_DIR) && make menuconfig
image:
	cd $(LINUX_BUILD_DIR) && make -j6 Image
	gzip -n -9 -c $(LINUX_BUILD_DIR)/arch/riscv/boot/Image > $(OUT_DIR)/Image.gz
dtb:
	cd $(LINUX_BUILD_DIR) && make -j6 dtbs
	cp $(LINUX_BUILD_DIR)/arch/riscv/boot/dts/starfive/jh7110-starfive-visionfive-2-v1.3b.dtb $(OUT_DIR)/
all:
	cd $(LINUX_BUILD_DIR) && make -j6 Image dtbs modules
	gzip -n -9 -c $(LINUX_BUILD_DIR)/arch/riscv/boot/Image > $(OUT_DIR)/Image.gz
	cp $(LINUX_BUILD_DIR)/arch/riscv/boot/dts/starfive/jh7110-starfive-visionfive-2-v1.3b.dtb $(OUT_DIR)/
fit:
	./gen-fit.sh $(OUT_DIR)/Image.gz $(OUT_DIR)/initramfs.cpio.gz $(OUT_DIR)/jh7110-starfive-visionfive-2-v1.3b.dtb $(OUT_DIR)/starfiveu.fit
clean:
	rm -r $(LINUX_BUILD_DIR)/
	cd $(LINUX_SOURCE_DIR) && make O=../$(LINUX_BUILD_DIR) defconfig
	cd ..
	cp linux-mainline.config $(LINUX_BUILD_DIR)/.config
enable:
	@echo "Enable config: $(CONFIG)"
	$(LINUX_SOURCE_DIR)/scripts/config --file $(LINUX_BUILD_DIR)/.config --enable $(CONFIG)
module:
	@echo "Module config: $(CONFIG)"
	$(LINUX_SOURCE_DIR)/scripts/config --file $(LINUX_BUILD_DIR)/.config --module $(CONFIG)
modules_install:
	cd $(LINUX_BUILD_DIR) && make INSTALL_MOD_PATH=/tmp/root_modules/ modules_install
	# FIXME: /root/out/ is absolute on my config. please make this relative.
	cd /tmp/root_modules/ && tar -czf /root/$(OUT_DIR)/modules.tar.gz lib/modules
