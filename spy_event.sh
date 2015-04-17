#!/bin/bash
# control event_spy engine in the FEM to latch the next event

SP_OPTION=""
USAGE="usage: $0 a/b arm/addr [aaa]; where aaa is a 3-digit hex address to start the dump"

#if [ "$#" -lt "3" ]; then echo $USAGE; exit; fi

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

#address should be 3-digit hex
ADDR=000
if [ "$#" -ge "3" ]; then ADDR=$3; fi

case "$2" in
  "arm") # reset event_spy, arm it and set for successive address access
     CMD="Play_stapl.py $SP_OPTION i22 0000 8000 C$ADDR |./splayer_dump.py"
     ;;
  "addr") # set the read address of the event_spy, 
     CMD="Play_stapl.py $SP_OPTION i22 4$ADDR |./splayer_dump.py"
     ;;
  *)
     echo $USAGE
     exit
esac

echo -e "Executing: $CMD"
# |./splayer_dump.py"
$CMD |./splayer_dump.py

echo "To dump more use: StaplPlayer $SP_OPTION -atrans dump1k.stp |./splayer_dump.py"
