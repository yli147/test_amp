wget -c http://riscv-sw-ci2.sh.intel.com:8000/test/spacemit/bianbu-23.10-desktop-k1-v1.0rc1-release-20240429194149.img
loopdevice=`sudo losetup --partscan --find --show ./bianbu-23.10-desktop-k1-v1.0rc1-release-20240429194149.img`
sudo dd if=${loopdevice}p5 of=/dev/sde5 bs=8M status=progress && sync
sudo dd if=${loopdevice}p6 of=/dev/sde6 bs=8M status=progress && sync

