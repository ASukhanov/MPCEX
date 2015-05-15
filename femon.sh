#!/bin/bash
usage()
{
cat << EOF
usage: $0 [femfake] [cbfake] [gray] [-v] 
EOF
}
# Activate FEMs
# 2015-02-17	Version FEMr1-r13E
# 2015-03-14    Version FEMr1-r174, Stop/Start sequencer

VERB="0"
LOG=/phenixhome/phnxrc/MPCEXFinal/StaplPlayer_log.txt

# Working  mode
CSR10=16#50000F08	# standard
#CSR10=16#50008F08	# Err_halt, all CB enabled,CB0 master
#CSR10=16#50008C28       # Err_halt, CB2:3 enabled, CB2-master
#CSR10=16#50008C38       # Err_halt, CB2:3 enabled, CB3-master
#CSR10=16#50008C28       # Err_halt, all enabled, CB2-master
#CSR10=16#50000108
#CSR10=16#50000D38	# CB2&3 enabled, CB3 master
#CSR10=16#50002D38       # CB2&3 enabled, CB3 master, PARst disabled

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
  -v)
    $VERB="1"
    ;;
  *)
    usage
    exit 1
    ;;
  esac
done

HEXNUM=`printf "%08x\n" $((CSR10))`

# Start sequencer, local reset, reset carriers, local L1 once
#CMD1="Play_stapl.py i16 aff00000 i10 50110fC8 70010fC8"

# Stop/Start sequencer, local reset, reset carriers, local L1 once
# This might reset the cellIDs on carriers
#CMD1="Play_stapl.py i16 1ff00000 aff00000 i10 50110fC8 70010fC8"

# The short version below with only sequencer start is sufficient.
CMD1="Play_stapl.py i16 aff00000 i10"

CMD2="Play_stapl.py i10 $HEXNUM"

if [ $VERB -eq "1" ]; then echo "$HOSTNAME: Executing $CMD1; $CMD2; on FEM a and b"; fi
#echo "$HOSTNAME: Executing $CMD1; $CMD2; on FEM a and b" >> $LOG

# Setup FEM and start sequencer on FEMa
#echo "Executing $CMD1"
eval $CMD1 > /dev/null
#echo "Executing $CMD2"
eval $CMD2 > /dev/null

# and on FEMb
#echo "Executing $CMD1 -g"
eval $CMD1 -g > /dev/null
#echo "Executing $CMD2 -g"
eval $CMD2 -g > /dev/null
