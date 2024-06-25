mkdir -p ./mnt/
sudo mount /dev/sde5 ./mnt/
dtc -I dts -O dtb -o k1-x_deb1-bianbu.dtb k1-x_deb1-bianbu.dts
# dtc -I dts -O dtb -o k1-x_deb1-bianbu.dtb k1-x_u-deb1.dts
sudo cp k1-x_deb1-bianbu.dtb ./mnt/spacemit/k1-x_deb1.dtb
sudo umount ./mnt


