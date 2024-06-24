# pushd ./linux-6.8.2
# make CROSS_COMPILE=/opt/riscv/bin/riscv64-unknown-linux-gnu- ARCH=riscv -j`nproc`
# popd

pushd linux-6.1
make ARCH=riscv CROSS_COMPILE="/opt/spacemit-toolchain-linux-glibc-x86_64-v1.0.1/bin/riscv64-unknown-linux-gnu-" -j16
popd

pushd opensbi
CROSS_COMPILE=/opt/riscv/bin/riscv64-unknown-linux-gnu- make -j$(nproc) PLATFORM_DEFCONFIG=k1_defconfig PLATFORM=generic BUILD_INFO=y
export OPENSBI=`realpath build/platform/generic/firmware/fw_dynamic.bin`
popd

pushd u-boot
CROSS_COMPILE=/opt/riscv/bin/riscv64-unknown-linux-gnu- make -j8
cp ../opensbi/build/platform/generic/firmware/fw_dynamic.itb .
cp ../linux-6.1/arch/riscv/boot/Image .
dtc -I dts -O dtb -o k1-x_opensbi-deb1.dtb ../k1-x_opensbi-deb1.dts
dtc -I dts -O dtb -o k1-x_rt-deb1.dtb ../k1-x_rt-deb1.dts
dtc -I dts -O dtb -o k1-x_u-boot-deb1.dtb ../k1-x_u-boot-deb1.dts
cp ../initramfs.cpio.gz .
truncate -s %64 u-boot-nodtb.bin
truncate -s %64 Image
truncate -s %64 initramfs.cpio.gz
./tools/mkimage -f u-boot-new3.its -A riscv -O u-boot -T firmware u-boot-new.itb
popd
