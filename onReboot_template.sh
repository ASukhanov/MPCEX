#!/bin/bash
# Configure GPIO of the RPi to access FEMs and carriers
# This file should be modified locally and copied to onReboot.sh
# version v2 2016-01-11. rm stapl.stp
# version v3 2016-02-19 GPIO definition from ~/.bashrc 
# version V4 2016-04-18 initialization of EMCO board

FEMIDA=F1
FEMIDB=F2

# for JTAG0
/usr/local/bin/gpio export $GPIO_JTAG0_CS out
/usr/local/bin/gpio -g mode $GPIO_JTAG0_CS out
/usr/local/bin/gpio -g write $GPIO_JTAG0_CS 0

# for JTAG1
/usr/local/bin/gpio export $GPIO_JTAG1_CS out
/usr/local/bin/gpio -g mode $GPIO_JTAG1_CS out
/usr/local/bin/gpio -g write $GPIO_JTAG1_CS 0

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

#initialize EMCO_AD5592 board (Bias source + NanoAmmeter) if exist.
/usr/local/bin/ad5592.sh -i
