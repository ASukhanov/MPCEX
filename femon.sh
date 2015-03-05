#!/bin/bash
# Activate FEMs
# 2015-02-17	Version FEMr1-r13E
LOG=/phenixhome/phnxrc/MPCEXFinal/StaplPlayer_log.txt

# Working  mode
CSR10=16#50000F08

for arg in "$@"
do
  case "$arg" in
  femfake)	# fake data from FEM
    CSR10=$((CSR10|0x4))
    ;;
  sclk)		# internal clock
    CSR10=$((CSR10&~0x00000008))
    ;;
  cbfake)	# fake data from carrier boards
    CSR10=$((CSR10|0x00100000))
    ;;
  gray)		# gray code 
    CSR10=$((CSR10|0x00001000))
    ;;
  esac
done

HEXNUM=`printf "%08x\n" $((CSR10))`
# Start sequencer, local clear, local L1 once, back to working state
CMD1="Play_stapl.py i16 aff00000 i10 50010fC8 70010fC8"
# Not sure, maybe the short version below with only sequencer start is sufficient.
#CMD1="Play_stapl.py i16 aff00000 i10"
CMD2="Play_stapl.py i10 $HEXNUM"

echo "$HOSTNAME: Executing $CMD1; $CMD2; on FEM a and b"
echo "$HOSTNAME: Executing $CMD1; $CMD2; on FEM a and b" >> $LOG

# Setup FEM and start sequencer on FEMa
#echo "Executing $CMD1"
$CMD1 > /dev/null
#echo "Executing $CMD2"
$CMD2 > /dev/null

# and on FEMb
#echo "Executing $CMD1 -g"
$CMD1 -g > /dev/null
#echo "Executing $CMD2 -g"
$CMD2 -g > /dev/null
