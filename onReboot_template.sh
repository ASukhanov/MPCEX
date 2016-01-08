# Configure select line of the RPiLVDS board
# This file should be modified locally and copied to onReboot.sh

# for JTAG0
gpio export 8 out
gpio -g mode 8 out
gpio -g write 8 0

# for JTAG1
gpio export 7 out
gpio -g mode 7 out
gpio -g write 7 0

# unload/load spi driver, the previous commands affect the spi driver access
#gpio unload spi
#gpio load spi

#'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
#### local section
#
# Assign FEM IDs (default f0 and f1),
# they should be changed locally at RPi to be unique.
# Assume IDs 11..18 for North and 21..23 for South

# Reset FEM and assign FEM ID for FEMa
Play_stapl.py i10 10000000 0 i23 f0 | ./splayer_dump.py

# The same for FEMb
Play_stapl.py i10 10000000 0 i23 f1 -g | ./splayer_dump.py
#,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,
