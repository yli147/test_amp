nc -z 127.0.0.1 54320 || /usr/bin/gnome-terminal -x ./soc_term.py 54320 &
nc -z 127.0.0.1 54321 || /usr/bin/gnome-terminal -x ./soc_term.py 54321 &
while ! nc -z 127.0.0.1 54320 || ! nc -z 127.0.0.1 54321; do sleep 1; done
./qemu/build/qemu-system-riscv64 \
        -machine virt -nographic -m 8G -smp 4 \
        -dtb ./qemu-virt-amp.dtb \
        -bios opensbi/build/platform/generic/firmware/fw_jump.elf \
        -kernel ./linux-6.8.2/arch/riscv/boot/Image \
        -device loader,file=./qemu-virt-amp-nw.dtb,addr=0xB2200000 \
        -device loader,file=./u-boot/u-boot.bin,addr=0xA0200000 \
        -device loader,file=./qemu-virt-amp-rtw.dtb,addr=0xA2200000 \
        -serial tcp:localhost:54320 -serial tcp:localhost:54321 \
        -initrd ./initramfs.cpio.gz -append "root=/dev/vda ro console=ttyS0" \
        -device virtio-net-device,netdev=eth0 -netdev user,id=eth0

