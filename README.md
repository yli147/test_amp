# Test AMP

Download this project
```
git clone https://github.com/yli147/test_amp.git -b k1-amp test_amp
cd test_amp
export WORKDIR=`pwd`
```

Compile OpenSBI
```
cd $WORKDIR
git clone https://github.com/yli147/opensbi.git -b k1-amp opensbi
pushd opensbi
CROSS_COMPILE=/opt/riscv/bin/riscv64-unknown-linux-gnu- make -j$(nproc) PLATFORM_DEFCONFIG=k1_defconfig PLATFORM=generic
export OPENSBI=`realpath build/platform/generic/firmware/fw_dynamic.bin`
popd
```

Compile Test Application
```
git clone https://github.com/yli147/test_context_switch.git -b k1-amp
pushd test_context_switch
make
popd
```

Compile U-boot (The ns-hello.bin must be 64 bits aligned, otherwise the device tree blob won't be in 64 bits address which will cause opensbi boot failue)
```
cd $WORKDIR
git clone https://github.com/yli147/u-boot.git -b k1-amp u-boot
pushd u-boot
make k1_defconfig
CROSS_COMPILE=/opt/riscv/bin/riscv64-unknown-linux-gnu- make -j8
cp ../opensbi/build/platform/generic/firmware/fw_dynamic.itb .
cp ../test_context_switch/build/s-hello/s-hello.bin .
cp ../test_context_switch/build/ns-hello/ns-hello.bin .
truncate -s %64 s-hello.bin
truncate -s %64 ns-hello.bin
./tools/mkimage -f u-boot-new.its -A riscv -O u-boot -T firmware u-boot-new.itb
popd
```

Flash Image (Make sure you have biandu_sdcard.img already flashed to the SDCard, then upgrade the SDCard with following steps )
```
dd if=u-boot/fw_dynamic.itb of=/dev/sdX3
dd if=u-boot/u-boot-new.itb of=/dev/sdX4
dd if=u-boot/FSBL.bin of=/dev/sdX1
```

Notes:
In the latest code u-boot device tree, I have added uart9 (GPIO72/GPIO73) as the default stdout uart, 
so you need connect GPIO72/73 with a UART terminal to see the opensbi log.
The u-boot-spl code also use the device tree, and keeps to use uart0 as the output

![image](https://github.com/yli147/test_amp/assets/21300636/8fcba632-7797-451c-860e-3fc0e64a3b99)


![image](https://github.com/yli147/test_amp/assets/21300636/b4f480e9-853b-43a6-9eaf-486ec4c2b945)


