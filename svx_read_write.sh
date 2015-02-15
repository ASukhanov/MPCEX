#!/bin/bash
# Shifts in/out the configuration stream into SVX chain
# It assumes that svx_conf_enable.sh/.shsvx_conf_disable.sh scrips are executed before/after
USAGE="usage: $0 [a/b]"
SP_OPTION=""
# CSR10[03:00]: BClk:08
CSR10_bits_03_00=0
LOG=/phenixhome/phnxrc/MPCEXFinal/StaplPlayer_log.txt
echo "^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ $HOSTNAME ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^" >> $LOG

case "$1" in
  "b0")
    SP_OPTION="-g"
    CSR10_bits_11_04="1C"
    ;;
  "b1")
    SP_OPTION="-g"
    CSR10_bits_11_04="2D"
    ;;
  "b2")
    SP_OPTION="-g"
    CSR10_bits_11_04="4E"
    ;;
  "b3")
    SP_OPTION="-g"
    CSR10_bits_11_04="8F"
    ;;
  "a0")
    SP_OPTION=""
    CSR10_bits_11_04="1C"
    ;;
  "a1")
    SP_OPTION=""
    CSR10_bits_11_04="2D"
    ;;
  "a2")
    SP_OPTION=""
    CSR10_bits_11_04="4E"
    ;;
  "a3")
    SP_OPTION=""
    CSR10_bits_11_04="8F"
    ;;
  *)
    echo $USAGE
    exit
esac

# setup carriers
#CMD="./svx_conf_enable.sh $SP_OPTION"
#echo "Executing: $CMD"
#echo "Executing: $CMD" >> $LOG
#$CMD >> $LOG

# setup FEM
CMD="Play_stapl.py $SP_OPTION i10 00010$CSR10_bits_11_04$CSR10_bits_03_00"
echo "Executing: $CMD"
echo "Executing: $CMD" >> $LOG
$CMD >> $LOG

# Download/readback of the configuration register
CMD="StaplPlayer $SP_OPTION -aTrans svxall_gain_high_drive_low.stp"
echo "Executing: $CMD"
echo "Executing: $CMD" >> $LOG
$CMD
# >> $LOG

# Disable SVX configuration
#CMD="svx_conf_disable.sh $SP_OPTION"
# do it quick way, by toggling BClkOff:
#svx_conf_disable.shCMD="Play_stapl.py $SP_OPTION i10 50110$CSR10_bits_11_04$CSR10_bits_03_00 00010$CSR10_bits_11_04$CSR10_bits_03_00 i1c 0"
#echo "Executing: $CMD"
#echo "Executing: $CMD" >> $LOG
#$CMD >> $LOG
echo "Do not forget to ./svx_conf_disable.sh when you are done"
echo "_______________________________ $HOSTNAME _________________________________" >> $LOG
