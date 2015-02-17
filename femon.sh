#!/bin/bash
# Activate FEMs
# 2015-02-17	Version FEMr1-r13E
LOG=/phenixhome/phnxrc/MPCEXFinal/StaplPlayer_log.txt

# Standard mode
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
CMD="Play_stapl.py i10 $HEXNUM i16 aff00000"
echo "$HOSTNAME: Executing $CMD on FEM a and b"
echo "$HOSTNAME: Executing $CMD on FEM a and b" >> $LOG

# Setup FEM and start sequencer on FEMa
$CMD > /dev/null

# and on FEMb
$CMD -g > /dev/null
