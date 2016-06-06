#!/bin/bash
# Flash the FEM or carrier board firmware with the latest FEM*.stp
ACTION="-aDevice_info" # Deafult action
SP_OPTION=""
USAGE="usage: $0 a/b[0:3] [Program/Verify/Read_IDCODE/...]"
FPGA="fem"

if [ $# == 0 ]; then echo $USAGE; exit; fi
if [ $1 == "b" ]; then SP_OPTION="-g"; fi
#if [ $# == 2 ]; then FPGA="fem; fi
if [ $# == 2 ]; then ACTION=-a$2; fi

SFILE=$(ls -t /phenixhome/phnxrc/MPCEX/FEM* | head -1)
CMD="StaplPlayer $SP_OPTION $ACTION $SFILE"

echo "Executing $CMD"
$CMD

if [ $ACTION == "-aProgram" ]; then
  #set default FEM ID
  echo "Setting default FEM ID=77: Play_stapl.py $SP_OPTION i23 77"
  Play_stapl.py $SP_OPTION i23 77
fi
