#!/bin/bash
# Stop sequencers on FEMs
LOG=/phenixhome/phnxrc/MPCEXFinal/StaplPlayer_log.txt

CMD="Play_stapl.py i16 1ff00000"
echo "$HOSTNAME: Executing $CMD on FEM a and b"
echo "$HOSTNAME: Executing $CMD on FEM a and b" >> $LOG

# FEMa
$CMD

# FEMb
$CMD -g

