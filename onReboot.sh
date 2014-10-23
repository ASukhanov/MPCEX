# configure select line of the RPiLVDS board

# for JTAG0
gpio export 8 out
gpio -g mode 8 out
gpio -g write 8 0

# for JTAG1
gpio export 7 out
gpio -g mode 7 out
gpio -g write 7 0
