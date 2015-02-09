#!/bin/bash
# Test sdo serial commands on carrier boards

USAGE="usage: $0 a/b 10/20/40/80 [bclk/sclk]"
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

CSR10=16#50000FC8
  case "$3" in
  bclk)
    CSR10=$((CSR10|0x00000008))
    ;;
  sclk)         # internal clock
    CSR10=$((CSR10&~0x00000008))
    ;;
  esac
HEXNUM=`printf "%08x\n" $((CSR10))`

#echo "Executing: Play_stapl.py $SP_OPTION i10 $HEXNUM i16 1ff00000 000000$1 001200$1 00200000 1ff00000 aff00000"
echo "sequencer:"
Play_stapl.py $SP_OPTION i10 $HEXNUM i16 1ff00000 000000$2 001200$2 00200000 1ff00000 aff00000 |./splayer_dump.py
echo "carrier board:"
Play_stapl.py $SP_OPTION -c i32 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 |./splayer_dump.py

