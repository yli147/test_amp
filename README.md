# Test AMP

Download this project
```
git clone https://github.com/intel-sandbox/personal.yli147.test_amp.git test_amp
cd test_amp
export WORKDIR=`pwd`
```

Compile QEMU
```
cd $WORKDIR
git clone https://github.com/qemu/qemu.git --depth 1 --branch v7.2.0
pushd qemu
git apply ../0001-Add-second-uart-for-secure-domain.patch
./configure --target-list=riscv64-softmmu --enable-slirp
make -j$(nproc)
popd
```

Compile OpenSBI

```
cd $WORKDIR
git clone https://github.com/intel-sandbox/personal.yli147.opensbi.git -b unmatched-amp opensbi
pushd opensbi
make CROSS_COMPILE=riscv64-linux-gnu- PLATFORM=generic INSTALL_LIB_PATH=lib FW_PIC=n
popd
```

Generate DTB
```
cd $WORKDIR
dtc -I dts -O dtb -o qemu-virt-amp.dtb ./qemu-virt-amp.dts
dtc -I dts -O dtb -o qemu-virt-amp-nw.dtb ./qemu-virt-amp-nw.dts
dtc -I dts -O dtb -o qemu-virt-amp-rtw.dtb ./qemu-virt-amp-rtw.dts

OR
./qemu/build/qemu-system-riscv64 \
	-machine virt,dumpdtb=qemu-virt.dtb -nographic -m 8G -smp 4 \
	-bios opensbi/build/platform/generic/firmware/fw_jump.elf \
	-kernel u-boot/u-boot.bin \
	-device virtio-net-device,netdev=eth0 -netdev user,id=eth0

dtc -I dtb -O dts -o qemu-virt-amp.dts ./qemu-virt.dtb
** Manually modify qemu-virt-amp.dts **
dtc -I dts -O dtb -o qemu-virt-amp.dtb ./qemu-virt-amp.dts
```

Compile U-boot
```
cd $WORKDIR
git clone https://github.com/intel-sandbox/personal.yli147.u-boot.git -b qemu-amp u-boot
pushd u-boot
CROSS_COMPILE=riscv64-linux-gnu- make qemu-riscv64_smode_defconfig
CROSS_COMPILE=riscv64-linux-gnu- make -j`nproc` menuconfig
General setup    
	(0xA0200000) Static location for the initial stack pointer
	(0xA0200000) Address in memory to use by default     
	(0xA0200000) Text Base   
	(0xA0200000) Physical start address of boot monitor code
Console                                                                                                                                       x
  	(0xA1000000) Address of the pre-console buffer
CROSS_COMPILE=riscv64-linux-gnu- make -j`nproc`
popd 
```

Compile Linux
```
cd $WORKDIR
wget -c https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-6.8.2.tar.xz
tar xvf linux-6.8.2.tar.xz
pushd linux-6.8.2
make CROSS_COMPILE=riscv64-linux-gnu- ARCH=riscv defconfig 
make CROSS_COMPILE=riscv64-linux-gnu- ARCH=riscv -j`nproc`
make CROSS_COMPILE=riscv64-linux-gnu- ARCH=riscv INSTALL_MOD_STRIP=1 -j`nproc` tarbz2-pkg
make CROSS_COMPILE=riscv64-linux-gnu- ARCH=riscv INSTALL_MOD_STRIP=1 -j`nproc` bindeb-pkg
popd
```

Run u-boot + linux (Need GUI):
```
cd $WORKDIR
./run.sh
```

Run dual Linux + Linux (Need GUI):

Create initrd for rt world os by following https://github.com/intel-sandbox/personal.yli147.riscv64-bringup/tree/master, or just use the initramfs.cpio.gz in this repo

Create Disk Image
```
cd $WORKDIR
git clone https://github.com/buildroot/buildroot.git -b 2023.08.x
pushd buildroot
make qemu_riscv64_virt_defconfig
make -j $(nproc)
ls ./output/images/rootfs.ext2
popd

dd if=/dev/zero of=disk.img bs=1M count=128
sudo sgdisk -g --clear --set-alignment=1 \
       --new=1:34:-0:    --change-name=1:'rootfs'    --attributes=3:set:2 \
	   disk.img
loopdevice=`sudo losetup --partscan --find --show disk.img`
echo $loopdevice
sudo mkfs.ext4 ${loopdevice}p1
sudo e2label ${loopdevice}p1 rootfs
mkdir -p mnt
sudo mount ${loopdevice}p1 ./mnt
sudo tar vxf buildroot/output/images/rootfs.tar -C ./mnt --strip-components=1
sudo mkdir ./mnt/boot
sudo cp -rf linux-6.8.2/arch/riscv/boot/Image ./mnt/boot
version=`cat linux-6.8.2/include/config/kernel.release`
echo $version

sudo mkdir -p .//mnt/boot/extlinux
cat << EOF | sudo tee .//mnt/boot/extlinux/extlinux.conf
menu title QEMU Boot Options
timeout 100
default kernel-$version

label kernel-$version
        menu label Linux kernel-$version
        kernel /boot/Image
        append root=/dev/vda1 ro earlycon console=ttyS0,115200n8

label recovery-kernel-$version
        menu label Linux kernel-$version (recovery mode)
        kernel /boot/Image
        append root=/dev/vda1 ro earlycon single
EOF
sudo umount ./mnt
sudo losetup -D ${loopdevice}
```

```
cd $WORKDIR
./run-disk.sh
```

Run Linux + RT Thread (Need GUI):
```
cd $WORKDIR
git clone https://github.com/intel-sandbox/personal.yli147.rt-thread.git -b rtthread_AMP rtthread
sudo tar xf rtthread/toolchain/tool-root1.tar.gz -C /opt/
pushd rtthread/bsp/starfive/jh7110
scons
popd

dtc -I dts -O dtb -o qemu-virt-new.dtb ./qemu-virt-new.dts

./qemu/build/qemu-system-riscv64 \
-machine virt -nographic -m 8G -smp 4 \
-dtb ./qemu-virt-new.dtb \
-bios opensbi/build/platform/generic/firmware/fw_jump.elf \
-kernel ./linux-6.8.2/arch/riscv/boot/Image \
-device loader,file=./rtthread/bsp/starfive/jh7110/rtthread.bin,addr=0xAE800000 \
-initrd ./initramfs.cpio.gz -append "root=/dev/vda ro console=ttyS0" \
-device virtio-net-device,netdev=eth0 -netdev user,id=eth0
```


