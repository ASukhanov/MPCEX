#!/bin/bash
usage()
{
cat << EOF
usage: $0 [a/b] OPTIONS

Enable FEMs for data taking

OPTIONS:
  -f    FEMfake, fake data from the FEM
  -c    CBFake, fake data from the carrier boards
  -g    disable Gray decoding in the FPGA
  -i    FrontEnd Clock sourced from the system clock
  -sN   skip sending out 2**(N-1) events, useful for etehrnet readout
  -vV   Verbosity = V
  -h    this message
EOF
}
# Activate FEMs
# 2015-02-17	Version FEMr1-r13E
# 2015-03-14    Version FEMr1-r174, Stop/Start sequencer
# 2015-12-03	FEMr1-v1EB, -l option
# 2015-12-24    -l removed as not needed since v1F8, -s option added

VERB="0"
LOG=/phenixhome/phnxrc/MPCEXFinal/StaplPlayer_log.txt

FEM="ab"
#echo "${#1}"
case "${1:0:1}" in
  "a"|"b")
    FEM=$1;OPTIND=2;;
esac
#echo "FEM=[$FEM]"

# Working  mode
CSR10=16#50000F08       # standard
#CSR10=16#50000F18        # CB1 master
#CSR10=16#50008F08      # Err_halt, all CB enabled,CB0 master
#CSR10=16#50000108      # CB0 enabled, CB0 master
#CSR10=16#50000218       # CB0,CB1,CB2,CB3 enabled, CB1 master.
#CSR10=16#5000071C       # FEMFake CB0,CB1CB2 enabled, CB1 master.

SKIP="0"        # do not skip events
#SKIP="1"        # skip every second event

#OPTIND=2        # skip first argument
while getopts "fcgis:v:h" opt; do
  #echo "opt=$opt"
  case $opt in
    f) CSR10=$((CSR10 | 0x4));        echo "FEMFAke mode on FEM $FEM";;  # FEMFake, fake data from FEM
    c) CSR10=$((CSR10 | 0x00100000)); echo "CBFake mode on FEM $FEM";;  # CBFake fake data from carrier boards
    g) CSR10=$((CSR10 | 0x00001000)); echo "Gray decoding disabled on FEM $FEM";;  # disable Gray decoding in FPGA, useful for FEMFake and CBFake
    i) CSR10=$((CSR10 &~0x00000008)); # internal clock
       CSR10=$((CSR10 | 0x00010000)); # local GTM
       echo "Internal clock on FEM $FEM"
       ;; # internal clock, accompanied by local GTM
    #l) CSR10=$((CSR10|0x00040000));echo "GTM switched to local";;
    s) SKIP=$OPTARG;;
    v) VERB=$OPTARG;;
    h) usage; exit;;
    \?) echo "Invalid option: -$OPTARG" >&2; exit 1;;
    :)  echo "Option -$OPTARG requires an argument." >&2; exit 1
esac
done
let "SKIPEV = 1<<($SKIP&0x3)"
if [ $SKIP -ne "0" ]; then echo "WARNING. EVENT SKIPPING IS ACTIVE! sending out only every $SKIPEV-th event"; fi

HEXNUM=`printf "%08x\n" $((CSR10))`

# Start sequencer, local reset, reset carriers, local L1 once
#CMD1="Play_stapl.py i16 aff00000 i10 50110fC8 70010fC8"

# Stop/Start sequencer, local reset, reset carriers, local L1 once
# This might reset the cellIDs on carriers
#CMD1="Play_stapl.py i16 1ff00000 aff00000 i10 50110fC8 70010fC8"

# The short version below with only sequencer start is sufficient.
CMD1="Play_stapl.py i16 aff00000"

CMD2="Play_stapl.py i10 $HEXNUM i20 $SKIP"

if [ $VERB -eq "1" ]; then echo "$HOSTNAME: Executing $CMD1; $CMD2; on FEM a and b"; fi
#echo "$HOSTNAME: Executing $CMD1; $CMD2; on FEM a and b" >> $LOG

# Setup FEM and start sequencer on FEMa
if [[ $FEM == *"a"* ]]; then
  if [ $VERB -gt "0" ]; then echo "Executing: $CMD1; $CMD2"; fi
  eval $CMD1 > /dev/null
  eval $CMD2 > /dev/null
fi

# and on FEMb
if [[ $FEM == *"b"* ]]; then
  if [ $VERB -gt "0" ]; then echo "Executing: $CMD1 -g; $CMD2 -g"; fi
  eval $CMD1 -g > /dev/null
  eval $CMD2 -g > /dev/null
fi
