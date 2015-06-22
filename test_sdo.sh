#!/bin/bash
# Test sdo serial commands on carrier boards
usage()
{
cat << EOF
usage: $0 a/b[i] command [bclk/sclk]

test serial commands on carrier board

OPTIONS:

EXAMPLES:
$0 b3 18 bclk # send FEClk for download mode in carrier b3 use beam clock
EOF
}

if [ "$#" -lt "3" ]; then usage; exit; fi

SP_OPTION=""
case "${1:0:1}" in
  "b")
    SP_OPTION="-g"
    ;;
  "a")
     SP_OPTION=""
    ;;
  *)
    usage
    exit
esac

if [ ${#1} -gt "2" ]; then usage; exit 1; fi
if [ ${#1} -eq "2" ]; then
case "${1:1:1}" in
  "0"|"1"|"2"|"3")
    CB="${1:1:1}"
    let "SM = 1<<$CB"
    ;;
  *) echo "carrier board id should be a0 through b3"; exit 1;;
esac
else usage; exit 1;
fi
echo "CB=$CB, Select mask = $SM"

#CSR10=16#000001C8	#: standard: CB0, bclk
#MASK=1
CSR10=16#00010${SM:0:1}${CB:0:1}8
#MASK=4

# Setup JTAG route for CB0
CMD="Play_stapl.py $SP_OPTION i1c $SM"
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
#CMD="Play_stapl.py $SP_OPTION i10 $HEXNUM i16 1ff00000 000000${2:0:2} 001200${2:0:2} 00200000 1ff00000 aff00000"
CMD="Play_stapl.py $SP_OPTION i10 $HEXNUM i16 1ff00000 000000${2:0:2} 001200000 aff00000"
echo "Executing: $CMD"
$CMD |./splayer_dump.py
#echo "sequencer:"
#Play_stapl.py $SP_OPTION i10 $HEXNUM i16 1ff00000 000000$2 001200$2 00200000 1ff00000 aff00000 |./splayer_dump.py
echo "carrier board:i32    i33      i32      i33      i32      i33      i32      i33"
Play_stapl.py $SP_OPTION -c i32 0 i33 0 i32 0 i33 0 i32 0 i33 0 i32 0 i33 0 i32 0 i33 0 i32 0 i33 0 i32 0 i33 0 i32 0 i33 0 |./splayer_dump.py

