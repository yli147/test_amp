ethercat download -p 0 -a 0 -t uint16 0x6040 0x00 0x06
sleep 1
ethercat download -p 0 -a 0 -t uint16 0x6040 0x00 0x07
sleep 1
ethercat download -p 0 -a 0 -t uint16 0x6040 0x00 0x0F
sleep 1
ethercat download -p 0 -a 0 -t uint16 0x6040 0x00 0x1F
sleep 1

# PV mode
ethercat download -p 0 -a 0 -t uint8 0x6060 0x00 0x03
sleep 1

# set velocity
ethercat download -p 0 -a 0 -t uint32 0x60FF 0x00 0x100000

echo "done"


# stop motor
# ethercat download -p 0 -a 0 -t uint16 0x6040 0x00 0x80

