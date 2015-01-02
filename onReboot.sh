# configure select line of the RPiLVDS board

# for JTAG0
gpio export 8 out
gpio -g mode 8 out
gpio -g write 8 0

# for JTAG1
gpio export 7 out
gpio -g mode 7 out
gpio -g write 7 0


# Assin FEM IDs (default 30 and 31), they should be changed locally at RPi to be unique.

# Reset FEM and assign FEM ID for FEMa
Play_stapl.py i10 10000000 0 i23 30

# The same for FEMb
Play_stapl.py i10 10000000 0 i23 31 -g

