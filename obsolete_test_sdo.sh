#!/bin/bash
# Test sdo serial commands on carrier boards
# This script work only with chain0.

USAGE="Old script, use test_serial_commands.sh instead.\n usage: $0 a/b 10/20/40/80 [bclk/sclk]"
if [ "$#" -lt "3" ]; then echo $USAGE; exit; fi

SP_OPTION=""
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

#CSR10=16#500001C8: only CB0, bclk 
CSR10=16#500001C8

# Setup JTAG route for CB0
MASK=1
CMD="Play_stapl.py $SP_OPTION i1c $MASK"
echo "Executing: $CMD"
$CMD |./splayer_dump.py

case "$3" in
  bclk)
    CSR10=$((CSR10|0x00000008))
    ;;
  sclk)         # internal clock
    CSR10=$((CSR10&~0x00000008))
    ;;
  esac

HEXNUM=`printf "%08x\n" $((CSR10))`
CMD="Play_stapl.py $SP_OPTION i10 $HEXNUM i16 1ff00000 000000$2 001200$2 00200000 1ff00000 aff00000"
echo "Executing: $CMD"
$CMD |./splayer_dump.py
#echo "sequencer:"
#Play_stapl.py $SP_OPTION i10 $HEXNUM i16 1ff00000 000000$2 001200$2 00200000 1ff00000 aff00000 |./splayer_dump.py
echo "carrier board:"
Play_stapl.py $SP_OPTION -c i32 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 |./splayer_dump.py

