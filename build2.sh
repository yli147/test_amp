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
dtc -I dts -O dtb -o k1-x_rt-deb1.dtb ../k1-x_rt-deb1.dts
truncate -s %64 u-boot-nodtb.bin
truncate -s %64 Image
./tools/mkimage -f u-boot-new2.its -A riscv -O u-boot -T firmware u-boot-new.itb
popd
