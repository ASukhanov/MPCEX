#!/bin/bash
# Control of the GTM_local engine in the MPCEX FEM
USAGE="usage: $0 [a/b] osc/random/stop [period=0:f] [ntrigs=0:f] [interval=0:3] [delay=00:ff]\n
where delay number of ticks is between L1 to PARst,period: f:0.6Hz, e:0.3Hz, 1:20khZ, 0:40KHz,\n
interval between L1s: 0,1,2,3: 16,32,64,128 ticks.\n
for example, single trigger: ./gtm_local.sh a start f 1 0 00; sleep 1;./gtm_local.sh a stop"


#frequency=F: ~1Hz
#frequency=0: ~65KHz
# example of single trigger:
EXAMPLE="./gtm_local.sh a start 01 1 f 1; sleep 1;./gtm_local.sh a stop"

DELAY="01"	# max= FF
NTRIGS="1"	# max = F
FREQ="1"	# max = F
CMDRUN="1"
INTERVAL="0"

if [ "$#" -lt "2" ]; then echo -e $USAGE; exit; fi

case "$1" in
  "b")
    SP_OPTION="-g"
    ;;
  "a")
     SP_OPTION=""
    ;;
  *)
    echo $USAGE
    exit
esac

case "$1" in
  "b")
    SP_OPTION="-g"
    ;;
  "a")
     SP_OPTION=""
    ;;
  *)  
    echo $USAGE
    exit
esac

if [ "$#" -ge "6" ]; then DELAY=$6; fi
if [ "$#" -ge "4" ]; then NTRIGS=$4; fi
if [ "$#" -ge "3" ]; then FREQ=$3; fi
if [ "$#" -ge "5" ]; then INTERVAL=$5; fi

case "$2" in
  "osc")
    echo "Periodic triggering: period=$FREQ, ntrigs=$NTRIGS, interval=$INTERVAL, delay=$DELAY"
    CMDRUN="3"
    ;;
  "random")
    echo "Random triggering"
    CMDRUN="1"
    ;;
  "stop")
    Play_stapl.py $SP_OPTION i26 0
    echo "Generator stopped"
    exit;
    ;;
  *)
    echo -e $USAGE
    exit
esac

let "NTRIGS = $NTRIGS-1"
if [ ${#DELAY} -ne "2" ]; then echo "Delay should be 2 digit, from 00 to ff"; exit; fi
DRSCAN=00$INTERVAL$CMDRUN$NTRIGS$DELAY$FREQ
if [ ${#DRSCAN} -ne "8" ]; then echo "$DRSCAN should be 8 digits"; exit; fi
CMD="Play_stapl.py $SP_OPTION i26 $DRSCAN"

echo "Executing: $CMD"
$CMD


