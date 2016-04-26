#!/bin/bash
usage()
{
cat << EOF
usage: $0 [a/b] options

Recover locked CellIDs
When no options provided:  send CalStrobe to carriers to reset the Cell IDs

OPTIONS:
  -d	download SVXs.
  -v N  verbosity, 0:3, default:$VERB.
  -f    file to download.
  -m M  Mask of bypassed modules. I.e to bypass module 4 use -m001000.

EXAMPLES:
$0 b		# quick recovery of locked Cell ID's
$0 b -v1	# also read back the SVX configurations on all chains
$0 b -d -v1	# re-download of SVXs on all chains
$0 a -d -v2 -m001000 # re-download all modules except 4 in all chains
EOF
}

#version 2 2015-08-18. corrected -f behavior
#version 3 2015-10-23. -m option added
#version v4 2015-12-08. CMD="Play_stapl.py i10 50100000 00000000 $SP_OPTION" # clear all carriers, GTM
#version v5 2016-04-05 CARLIST

VERB=1
DOWNLOAD=1
SEQUENCER_MODIFIED=0

# Default settings
FEM_SETTING="Play_stapl.py i10 50000F08" # default. All CBs will be downloaded simultaneously, CB0 - master
CARRIER_OPTIONS="-b000000" # no bypassed modules
# for PHENIX:
#FILE="svx6.stp"
#CARLIST=(0 1 2 3)
# for SC1F:
FILE="svx1.stp"
CARLIST=(0 1)
SVX_DOWNLOAD_LOG="svx_download.log"

# options for debugging
#FEM_SETTING="Play_stapl.py i10 50000d38"     # CB0,2,3 enabled, CB3 - master
#FEM_SETTING="Play_stapl.py i10 50000308"     # CB0,1 enabled, CB0 - master
#FEM_SETTING="Play_stapl.py i10 50000528"     # CB0,2 enabled, CB2 - master

OPTIND=2        # skip first argument
while getopts "v:f:dm:" opt; do
  #echo "opt=$opt"
  case $opt in
    d) DOWNLOAD="1";;
    f) FILE=$OPTARG;;
    v) VERB=$OPTARG;;
    m) CARRIER_OPTIONS=-b$OPTARG; echo "Mask of bypassed modules is set to $CARRIER_OPTIONS";;
    \?) echo "Invalid option: -$OPTARG" >&2; exit 1;;
    :)  echo "Option -$OPTARG requires an argument." >&2; exit 1
esac
done

case "${1:0:1}" in
  "b") SP_OPTION="-g";;
  "a")  SP_OPTION="";;
  *) usage; exit;;
esac

#v4
CMD="Play_stapl.py i10 50100000 00000000 $SP_OPTION" # clear all carriers, GTM local, CB0 master, BClk internal, Enable BClk for carriers
echo "executing: $CMD"
eval $CMD > /dev/null

echo "executing ./carrier_config.sh ${1:0:1} $CARRIER_OPTIONS -d -p8"
./carrier_config.sh ${1:0:1} $CARRIER_OPTIONS -d -p8;	# FEMODE=0, SVX downloading enabled

if [ $DOWNLOAD == "1" ]; then
echo "executing ./svx_download.sh $1 -v0 -f $FILE"
date >> $SVX_DOWNLOAD_LOG
./svx_download.sh $1 -v0 -f $FILE | tee >> $SVX_DOWNLOAD_LOG;  # download the chain;
#./view_status.sh $1
./send_calstrobe_to_carrier.sh ${1:0:1}; # latch the downloading
SEQUENCER_MODIFIED=1;
fi

if [ $VERB -ge "1" ]; then
# read back the configuration of all chains
echo "reading back configuration on all chains"
for ii in ${CARLIST[*]}
do
  CMD="./svx_download.sh ${1:0:1}$ii -v$VERB -f $FILE;"
  echo "Executing $CMD"
  eval $CMD
done
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

