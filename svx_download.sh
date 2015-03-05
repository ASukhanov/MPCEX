#!/bin/bash
# Download all chains at once
USAGE="usage: $0 [a/b]"
SP_OPTION=""
# CSR10: All chains enabled (f00), triggers disabled (c0) , BClk (8)
CSR10_bits_19_00=10fc0
LOG=/phenixhome/phnxrc/MPCEXFinal/StaplPlayer_log.txt
echo "^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ $HOSTNAME ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^" >> $LOG

case "$1" in
  "b")
    SP_OPTION="-g"
    ;;
  "a")
     SP_OPTION=""
    ;;
  *)
    echo $USAGE
    exit
esac
# Reset carriers
CMD="Play_stapl.py $SP_OPTION i10 000$CSR10_bits_19_00"
echo "Executing: $CMD"
echo "Executing: $CMD" >> $LOG
$CMD > /dev/null
# Download
CMD="StaplPlayer $SP_OPTION -aTrans svxall_gain_high_drive_low.stp"
echo "Executing: $CMD"
echo "Executing: $CMD" >> $LOG
# Dont need the output, it is useless 
$CMD > /dev/null
# send calstrobe to all carriers
CMD="Play_stapl.py $SP_OPTION i16 1ff00000 40 00120000 00200000 1ff00000 4ff00000"
echo "Executing: $CMD"
echo "Executing: $CMD" >> $LOG
$CMD > /dev/null
echo "Calstrobe sent"
echo "Calstrobe sent" >> $LOG
# Reset carriers
CMD="Play_stapl.py $SP_OPTION i10 501$CSR10_bits_19_00 000$CSR10_bits_19_00"
echo "Executing: $CMD"
echo "Executing: $CMD" >> $LOG
$CMD > /dev/null
echo "_______________________________ $HOSTNAME _________________________________" >> $LOG
