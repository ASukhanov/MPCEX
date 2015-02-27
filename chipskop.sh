#!/bin/bash
# Control of the FEM on-board logic analyzer
USAGE="usage: $0 [a/b] arm_l1/arm_seq/arm_gap/plot [trig_offset=0:F] "

TRIG_OFFSET=0
SP_OPTION=""
CSK_START=1
CSK_SELECT_CARB0_D=2
CSK_SELECT_GTM=4

CSK_IDLE=0
CSK_RUN=$(($CSK_START+$CSK_IDLE))
#echo $CSK_RUN

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
     ARM=0
    ;;
  "arm_seq")
     ARM=1
    ;;
  "arm_gap")
     ARM=2
    ;;
  "plot")
     ./plot_chipskop.py $1
     exit
    ;;
  *)
    echo $USAGE
    exit
esac
CMD="Play_stapl.py $SP_OPTION i1e $ARM$CSK_RUN$TRIG_OFFSET $ARM$CSK_IDLE$TRIG_OFFSET" # |./splayer_dump.py"
echo "Executing: $CMD"
$CMD
# > /dev/null
