mkdir -p ./mnt/

sudo mount /dev/sdf5 ./mnt/
dtc -I dts -O dtb -o k1-x_deb1-bianbu.dtb k1-x_deb1-bianbu.dts
sudo cp k1-x_deb1-bianbu.dtb ./mnt/spacemit/k1-x_deb1.dtb
sudo cp linux-6.1-rc1/arch/riscv/boot/Image.itb ./mnt/vmlinuz-6.1.15
sudo umount ./mnt



