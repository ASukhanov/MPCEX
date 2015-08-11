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

#'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
#### local section
#
# Assin FEM IDs (default f0 and f1), 
# they should be changed locally at RPi to be unique.

# Reset FEM and assign FEM ID for FEMa
Play_stapl.py i10 10000000 0 i23 f0

# The same for FEMb
Play_stapl.py i10 10000000 0 i23 f1 -g
#,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,
