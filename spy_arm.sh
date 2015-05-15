#!/bin/bash
# arm event_spy engine in the FEM to latch the next event

SP_OPTION=""
USAGE="usage: $0 [a/b] [aaa]; where aaa is a 3-digit hex address to start the dump"

#if [ "$#" -lt "2" ]; then echo $USAGE; exit; fi

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
if [ "$#" -ge "2" ]; then ADDR=$2; fi

# check if 
CMD="Play_stapl.py $SP_OPTION i22 0000 8000 C$ADDR |./splayer_dump.py"

echo -e "Executing: $CMD"
# |./splayer_dump.py"
$CMD |./splayer_dump.py

echo "To dump more use: StaplPlayer $SP_OPTION -atrans dump1k.stp |./splayer_dump.py"
