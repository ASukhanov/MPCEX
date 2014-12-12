# configure select line of the RPiLVDS board

# for JTAG0
gpio export 8 out
gpio -g mode 8 out
gpio -g write 8 0

# for JTAG1
gpio export 7 out
gpio -g mode 7 out
gpio -g write 7 0


# Assing FEM IDs, they should be different for all FEMs at PHENIX.

# assign FEM ID for FEMa
Play_stapl.py i23 10

# assign FEM ID for FEMb
Play_stapl.py i23 11 -g

