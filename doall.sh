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
VERB="0"
DOWNLOAD=0
SEQUENCER_MODIFIED=0
# Standard settings, to be used at PHENIX
CARRIER_OPTIONS=""
FEM_SETTING=""

# Local settings, for test bench
#FILE="svx3.stp"
#CARRIER_OPTIONS="-b011010" # bypass modules 2,4,5
#CARRIER_OPTIONS="-b001110 -n -p14" # bypass modules 2,3,4, CN mode, connect SDI probe to SDI
#FILE="svx5.stp"
#CARRIER_OPTIONS="-b000010"      # bypass modules 2
FILE="svx6.stp"
CARRIER_OPTIONS="-b000000"

FEM_SETTING="Play_stapl.py i10 50000F08"     # all CBs enabled, CB0 - master
#FEM_SETTING="Play_stapl.py i10 50000C38"     # CB2,3 enabled, CB3 - master

OPTIND=2        # skip first argument
while getopts ":v:f:d" opt; do
  #echo "opt=$opt"
  case $opt in
    d) DOWNLOAD="1";;
    f) FILE=$FILE;;
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

./carrier_config.sh ${1:0:1} $CARRIER_OPTIONS -d;	# FEMODE=0, SVX downloading enabled
if [ $DOWNLOAD == 1 ]; then
#echo "executing ./svx_download.sh $1 -v -f $FILE"
./svx_download.sh $1 -v0 -f $FILE;  # download the chain;
SEQUENCER_MODIFIED=1;
fi
#./view_status.sh $1
./send_calstrobe_to_carrier.sh ${1:0:1}; # latch the downloading
if [ $VERB -ge "1" ]; then
# read back the configuration
./svx_download.sh ${1:0:1}0 -v1 -f $FILE;
./svx_download.sh ${1:0:1}1 -v1 -f $FILE;
./svx_download.sh ${1:0:1}2 -v1 -f $FILE;
./svx_download.sh ${1:0:1}3 -v1 -f $FILE;
SEQUENCER_MODIFIED=1;
fi

./carrier_config.sh ${1:0:1} $CARRIER_OPTIONS	# FEMODE=1, ACQUIRE mode at SVXs
if [ $SEQUENCER_MODIFIED == 1 ]; then
./sequencer.sh ${1:0:1} trig;	# set sequencer
fi
./femon.sh
#echo $FEM_SETTING $SP_OPTION
eval $FEM_SETTING $SP_OPTION > /dev/null;
./view_status.sh ${1:0:1};

