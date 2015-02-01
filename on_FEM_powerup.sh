#!/bin/bash
# Initialize FEMs into ready to run state.
# Should be executed after onReboot.sh

# Setup sequencer
IRSCAN="Play_stapl.py $SP_OPTION i16 "
# with periodic PARst: 
DRSCAN="00000020 00110800 002000E0 00320020"
# only continuous FEClk:w
#DRSCAN="00000020 00110800 00220020"

# on FEM a
CMD="$IRSCAN $DRSCAN"
echo "Executing: $CMD"
$CMD >/dev/null
# on FEM b
CMD="$IRSCAN $DRSCAN -g"
echo "Executing: $CMD"
$CMD >/dev/null

# Setup FEMs
# Default is BClk and no tests
CSR10="50000f08"
# on FEM a
CMD="Play_stapl.py i10 $CSR10"
echo "Executing: $CMD"
$CMD >/dev/null
# on FEM b
CMD="Play_stapl.py i10 $CSR10 -g"
echo "Executing: $CMD"
$CMD >/dev/null

# Start sequencer
# on FEM a
CMD="Play_stapl.py i16 aff00000"
echo "Executing: $CMD"
$CMD >/dev/null
# on FEM b
CMD="Play_stapl.py i16 aff00000 -g"
echo "Executing: $CMD"
$CMD >/dev/null
