#!/bin/bash
# Control of the GTM_local engine in the MPCEX FEM
# Control of the GTM_local engine in the MPCEX FEM
usage ()
{
cat << EOF
usage: usage: $0 a/b options gentype [options gentype ...] 

Control of the GTM_local engine on the FEM.a or FEM.b

OPTIONS:
  options for periodic triggers:
  -p P	period [P=0:15]. P=15: 0.6Hz, P=14: 0.3Hz, ..., P=1: 20KHz, P=0: 40KHz
  -t T	Number of triggers [T=0:15] in train.
  -i I	Interval between triggers in train [I=0:7]. I=0: 16 ticks (1.6us), I=1: 32 ticks ....
  -d D	delay of first trigger relative to Abort Gap  pulse [D=0:255]

GENTYPE:
  -g G  generator type:
        en            start periodic trigger generator
        rand          start pseudo random trigger generator
        stop          stop generator, default

EXAMPLE:
	short run with random pulse generation:
  $0 b -g rand -g stop
EOF
}
# the fastest working setting for gigabit ethernet and sending every second event: './gtm_local.sh a osc 4 5 5'
# note, to drop every second event: 'Play_stapl.py i20 1'

#EXAMPLE="./gtm_local.sh a -g osc -t3; sleep 1; ./gtm_local.sh a stop"

GENTYPE=""
DELAY="1"
NTRIGS="1"
FREQ="2"

# dqcapture frequencies for L1Stack=5, interval=4
#		writing		not writing
#FREQ="3"                       5700 Hz
#FREQ="4"			3060 Hz
#FREQ="5"	# 1350 Hz	1530 Hz
#FREQ="6"       # 740 Hz
#FREQ="7"       # 370 Hz
#FREQ="8"       # 190 Hz
#FREQ="a"       # 50 Hz

CMDRUN=1
INTERVAL=4	# 13.4 us default, four of L1s during SVX busy = 46uS
#INTERVAL="1"	# 1.6 us
#INTERVAL="2"   # 3.4 us
#INTERVAL="3"   # 6.7 us
#INTERVAL="4"   # 13.4 us
#INTERVAL="5"   # 26.8 us, L1[1] infirst readout, L1[2:3] in second readout, which starts at 52 us, third - at 68
#INTERVAL="6"   # 53.6 us
#INTERVAL="7"   # 107.2 us
#INTERVAL="8"   # 214.4 us

if [ "$#" -lt "1" ]; then usage; exit; fi

case "$1" in
  "b")	SP_OPTION="-g";;
  "a")	SP_OPTION="";;
  *) 	usage; exit 1;;
esac

#'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
#	Execute the command
execmd () {
case "$GENTYPE" in
  "en") echo "Periodic triggering: period=$FREQ, ntrigs=$NTRIGS, interval=$INTERVAL, delay=$DELAY"
        CMDRUN="3";;
  "rand")     echo "Random triggering"; CMDRUN="1";;
  *)     Play_stapl.py $SP_OPTION i26 0 >> /dev/null; echo "Generator stopped"; exit;;
esac
#let "NTRIGS = $NTRIGS-1"
let "NTRIGS = $NTRIGS" # for firmware version after FEM-v1D2
let "DRSCAN = $INTERVAL<<20 | $CMDRUN<<16 | $NTRIGS<<12 | $DELAY<<4 | $FREQ"
DRSCAN=`printf "%08x\n" $DRSCAN`

CMD="Play_stapl.py $SP_OPTION i26 $DRSCAN"

echo "Executing: $CMD"
eval $CMD >> /dev/null
}
#,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,

OPTIND=2        # skip first arguments
while getopts ":p:t:i:d:c:g:h" opt; do
  #echo "opt=$opt"
  case $opt in
    p)  let "FREQ =     $OPTARG & 16#F";;
    d)  let "DELAY =    $OPTARG & 16#FF";;
    t)  let "NTRIGS =   $OPTARG & 16#F";;
    i)  let "INTERVAL = $OPTARG & 16#FF";;
    g)  GENTYPE=$OPTARG; execmd;;
    h)  usage;;
    ?)  echo "ERROR, Illegal option"; exit 1;;
    *)  ;;
  esac
done
if [ $FREQ == "6" ]; then echo "Note option -p6 will produce false locked up cell IDs"; fi
shift $((OPTIND-1))
if [ $# -ne 0 ]; then echo "Illegal comand: $1"; fi

