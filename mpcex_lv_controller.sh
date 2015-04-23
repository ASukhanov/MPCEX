#!/bin/bash
echo "MPCEX Power Distribution serial control"
echo "Channel On/Off mask: #20S00000FF where FF is mask for 8 channels"
echo "Analog Voltage: #20S10C where C is a channel from 0 to 7"
echo "Digital Volate: #20S20C where C is a channel from 0 to 7"
echo "Input Voltages: #20S30C where C is a channel from 0 to 3"
echo "Version: $20F"
echo "to exit: ctrl+]"
miniterm.py -p /dev/ttyUSB0 -b 38400

