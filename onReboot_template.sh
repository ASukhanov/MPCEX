#!/bin/bash
# Configure select line of the RPiLVDS board
# This file should be modified locally and copied to onReboot.sh
# version 2016-01-11. rm stapl.stp
FEMIDA=F1
FEMIDB=F2

# for JTAG0
/usr/local/bin/gpio export 8 out
/usr/local/bin/gpio -g mode 8 out
/usr/local/bin/gpio -g write 8 0

# for JTAG1
/usr/local/bin/gpio export 7 out
/usr/local/bin/gpio -g mode 7 out
/usr/local/bin/gpio -g write 7 0

# unload/load spi driver, the previous commands affect the spi driver access
#gpio unload spi
#gpio load spi
echo "GPIO done"

#'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
#### local section
#
# Assign FEM IDs (default f0 and f1),
# they should be changed locally at RPi to be unique.
# Assume IDs 11..18 for North and 21..23 for South
cd /home/phnxrc/work/MPCEX
# Reset FEM and assign FEM ID for FEMa
/usr/local/bin/Play_stapl.py i10 10000000 0 i23 $FEMIDA
# | /home/phnxrc/work/MPCEX/splayer_dump.py
# The same for FEMb
/usr/local/bin/Play_stapl.py i10 10000000 0 i23 $FEMIDB -g
# | /home/phnxrc/work/MPCEX/splayer_dump.py
#,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,
echo "FEMIDs set to $FEMIDA $FEMIDB"
# remove temporary file, created by Splayer
rm /run/shm/stapl.stp
