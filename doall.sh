#!/bin/bash
usage()
{
cat << EOF
usage: $0 [a/b] options

Recover locked CellIDs
When no options provided:  send CalStrobe to carriers to reset the Cell IDs

OPTIONS:
  -d	download SVXs
  -v N  verbosity, 0:3, default:$VERB
  -f    file to download

EXAMPLES:
$0 b		# quick recovery of locked Cell ID's
$0 b -v1	# also read back the SVX configurations on all chains
$0 b -d -v1	# re-download of SVXs on all chains
EOF
}

#version 2 2015-08-18. corrected -f behavior

VERB="0"
DOWNLOAD=0
SEQUENCER_MODIFIED=0

# Standard settings, to be used at PHENIX
FEM_SETTING="Play_stapl.py i10 50000F08" # default. All CBs will be downloaded simultaneously, CB0 - master
FILE="svx6.stp"
CARRIER_OPTIONS="-b000000" # no bypassed modules

#''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
# Local settings, for test bench
#FILE="svx1.stp"	# download one module
#CARRIER_OPTIONS="-b111111" # bypass all modules
#CARRIER_OPTIONS="-b011111" # bypass all except 6

#FILE="svx3.stp"
#CARRIER_OPTIONS="-b001110" # bypass modules 4,3,2
#CARRIER_OPTIONS="-b010110" # bypass modules 5,3,2
#CARRIER_OPTIONS="-b001110 -n -p14" # bypass modules 4,3,2, CN mode, connect SDI probe to SDI

#FILE="svx4.stp"
#CARRIER_OPTIONS="-b000110"      # bypass modules 2,5

#FILE="svx5.stp"
#CARRIER_OPTIONS="-b000010"      # bypass module 2
#,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,

# options for debugging
#FEM_SETTING="Play_stapl.py i10 50000d38"     # CB0,2,3 enabled, CB3 - master
#FEM_SETTING="Play_stapl.py i10 50000308"     # CB0,1 enabled, CB0 - master
#FEM_SETTING="Play_stapl.py i10 50000528"     # CB0,2 enabled, CB2 - master

OPTIND=2        # skip first argument
while getopts ":v:f:d" opt; do
  #echo "opt=$opt"
  case $opt in
    d) DOWNLOAD="1";;
    f) FILE=$OPTARG;;
    v) VERB=$OPTARG;;
    \?) echo "Invalid option: -$OPTARG" >&2; exit 1;;
    :)  echo "Option -$OPTARG requires an argument." >&2; exit 1
esac
done

case "${1:0:1}" in
  "b") SP_OPTION="-g";;
  "a")  SP_OPTION="";;
  *) usage; exit;;
esac

echo "executing ./carrier_config.sh ${1:0:1} $CARRIER_OPTIONS -d -p8"
./carrier_config.sh ${1:0:1} $CARRIER_OPTIONS -d -p8;	# FEMODE=0, SVX downloading enabled

if [ $DOWNLOAD == "1" ]; then
echo "executing ./svx_download.sh $1 -v0 -f $FILE"
./svx_download.sh $1 -v0 -f $FILE;  # download the chain;
#./view_status.sh $1
./send_calstrobe_to_carrier.sh ${1:0:1}; # latch the downloading
SEQUENCER_MODIFIED=1;
fi

if [ $VERB -ge "1" ]; then
# read back the configuration of all chains
echo "reading back configuration on all chains"
./svx_download.sh ${1:0:1}0 -v$VERB -f $FILE;
./svx_download.sh ${1:0:1}1 -v$VERB -f $FILE;
./svx_download.sh ${1:0:1}2 -v$VERB -f $FILE;
./svx_download.sh ${1:0:1}3 -v$VERB -f $FILE;
SEQUENCER_MODIFIED=1;
fi

CMD="./carrier_config.sh ${1:0:1} $CARRIER_OPTIONS"   # FEMODE=1, ACQUIRE mode at SVXs
echo "executing $CMD"
$CMD

if [ $SEQUENCER_MODIFIED == 1 ]; then
./sequencer.sh ${1:0:1} trig;	# set sequencer
fi
#./femon.sh
#echo $FEM_SETTING $SP_OPTION
eval $FEM_SETTING $SP_OPTION > /dev/null;
./view_status.sh ${1:0:1};

