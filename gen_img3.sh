dd if=/dev/zero of=disk.img bs=1M count=40
sudo sgdisk -g --clear --set-alignment=1 \
       --new=1:256:+256K:    --change-name=1:'fsbl' --attributes=3:set:2 \
       --new=2:768:+64K:  --change-name=2:'env' --attributes=3:set:2 \
       --new=3:896:+384K:   --change-name=3:'opensbi' --attributes=3:set:2  \
	--new=4:1664:+36M:   --change-name=4:'uboot'  --attributes=3:set:2  \
       disk.img
# loopdevice2=`sudo losetup --partscan --find --show ./bianbu-linux-k1-sdcard.img`
# sudo dd if=${loopdevice2}p2 of=env.bin
# sudo losetup -D ${loopdevice2}
loopdevice=`sudo losetup --partscan --find --show ./disk.img`
sudo dd if=u-boot/u-boot-new.itb of=${loopdevice}p4
sudo dd if=u-boot/fw_dynamic.itb of=${loopdevice}p3
sudo dd if=u-boot/FSBL.bin of=${loopdevice}p1
sudo dd if=env.bin of=${loopdevice}p2
sudo dd if=bootinfo_sd.bin of=${loopdevice}
sudo losetup -D ${loopdevice}
sudo dd if=disk.img of=/dev/sde bs=8M status=progress && sync
