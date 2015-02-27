#!/bin/bash
# Control of the FEM on-board logic analyzer
TRIG_OFFSET=0
SP_OPTION=""
USAGE="usage: $0 [a/b] arm_l1/arm_seq/plot [trig_offset=0:F] "

if [ "$#" -ge "3" ]; then TRIG_OFFSET=$3; fi

CMD=""
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

case "$2" in
  "arm_l1")
     CMD="Play_stapl.py $SP_OPTION i1e 1$TRIG_OFFSET 0$TRIG_OFFSET" # |./splayer_dump.py"
    ;;
  "arm_seq")
     CMD="Play_stapl.py $SP_OPTION i1e 11$TRIG_OFFSET 10$TRIG_OFFSET" # |./splayer_dump.py"
    ;;  
  "plot")
     CMD="./plot_chipskop.py"
    ;;
  *)
    echo $USAGE
    exit
esac

echo "Executing: $CMD"
$CMD
# > /dev/null
