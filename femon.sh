#!/bin/bash
# Activate FEMs

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
echo Executing: Play_stapl.py i10 $HEXNUM i16 aff00000

# Setup FEM and start sequencer on FEMa
Play_stapl.py i10 $HEXNUM i16 aff00000 > /dev/null

# and on FEMb
Play_stapl.py i10 $HEXNUM i16 aff00000 -g > /dev/null
