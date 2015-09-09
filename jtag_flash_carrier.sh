#!/bin/bash
VERB="1"
FILE="CARB_U1-vE1.stp"
ACTION="DEVICE_INFO"
GPIO="8"  # GPIO line of the RPi to switch between FEMs

usage()
{
cat << EOF
usage: $0 a/bN options

Configure FPGA on the carrier board

OPTIONS:
  -f    file to download
  -p    program FPGA
  -r    read/verify FPGA
EOF
}

FILE=$(ls -t /phenixhome/phnxrc/MPCEX/CAR* | head -1)

OPTIND=2        # skip first argument
while getopts ":v:f:dhpr" opt; do
  case $opt in
    f) FILE=$OPTARG;;
    v) VERB=$OPTARG;;
    h) usage; exit 1;;
    p) ACTION="PROGRAM";;
    r) ACTION="VERIFY";;
    \?) echo "Invalid option: -$OPTARG" >&2; exit 1;;
    :)  echo "Option -$OPTARG requires an argument." >&2; exit 1
esac
done

#select FEM
FEM=${1:0:1}
case "$FEM" in
  "b") SP_OPTION="-g";;
  "a") SP_OPTION="";;
  *)echo "FEM should be a or b"; usage; exit 1;;
esac

#select  carrier
CB=${1:1:1}
if [ "$CB" -lt "0" -o "$CB" -gt "3" ]; then echo "Carrier board should be 0:3"; usage; exit 1; fi

let "I1C = 1<<$CB"
HEXNUM=`printf "%x\n" $I1C`

CMD="Play_stapl.py $SP_OPTION i1c $HEXNUM"
if [ $VERB -ge "1" ]; then echo "Executing: $CMD"; fi
eval $CMD >> /dev/null

CMD="gpio -g $SP_OPTION write $GPIO 1"
if [ $VERB -ge "1" ]; then echo "Executing: $CMD"; fi
eval $CMD

CMD="StaplPlayer $SP_OPTION -a$ACTION $FILE"
if [ $VERB -ge "1" ]; then echo "Executing: $CMD"; fi
eval $CMD

CMD="gpio -g $SP_OPTION write $GPIO 0"
if [ $VERB -ge "1" ]; then echo "Executing: $CMD"; fi
eval $CMD

