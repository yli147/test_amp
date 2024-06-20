pushd test_context_switch
make
popd

pushd opensbi
CROSS_COMPILE=/opt/riscv/bin/riscv64-unknown-linux-gnu- make -j$(nproc) PLATFORM_DEFCONFIG=k1_defconfig PLATFORM=generic BUILD_INFO=y
export OPENSBI=`realpath build/platform/generic/firmware/fw_dynamic.bin`
popd

pushd u-boot
CROSS_COMPILE=/opt/riscv/bin/riscv64-unknown-linux-gnu- make -j8
cp ../opensbi/build/platform/generic/firmware/fw_dynamic.itb .
cp ../test_context_switch/build/s-hello/s-hello.bin .
cp ../test_context_switch/build/ns-hello/ns-hello.bin .
truncate -s %64 s-hello.bin
truncate -s %64 ns-hello.bin
./tools/mkimage -f u-boot-new.its -A riscv -O u-boot -T firmware u-boot-new.itb
popd
