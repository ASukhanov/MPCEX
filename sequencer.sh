#!/bin/bash
# Setup the sequencer for different types of run
# Note, the sequencer Repeat command (code xxx1nnnn repeats the previous command nnnn times 
SP_OPTION=""
USAGE="usage: $0 [a/b] [trig/ped/cal/svx)"

if [ "$#" -lt "2" ]; then echo $USAGE; exit; fi

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

IRSCAN="Play_stapl.py $SP_OPTION i16 "


case "$2" in
  cal) # for internal trigger with CalSR
    DRSCAN="1FF00000 00000020 00110002 002000E0 00300020 00410008 00500060 00600020 00710002 008000A0 00900020 00A10800 00B20020 00C00000 1FF00000"
#                          FM       R2       FM+PARst FM       R8       FM+Cal   FM       R2       FM+L1    FM       R800     FM+EOL
    ;;
  ped) # for internal trigger without CalSR
    DRSCAN="1FF00000 00000020 00110002 002000E0 00300020 00410008 00500020 00600020 00710003 008000A0 00900020 00A10100 00B20020 00C00000 1FF00000"
#                          FM       R2       FM+PARst FM       R8       FM       FM       R3       FM+L1    FM       R800     FM+EOL
    ;;
  trig) # For external trigger
    DRSCAN="1FF00000 00000020 00110800 002000E0 00320020 00400000 1FF00000"
#                          FM       R800     FM+PARst FM+EOL
    ;;
  svx) # For downloading SVXs
    DRSCAN="1FF00000 00000020 0012000 00300000 1FF00000"
    ;;
  *)
    echo "usage: $0 ped/cal/trig/svx"
    exit
esac

CMD="$IRSCAN $DRSCAN"

#CMD_FEM_b="$CMD -g"

echo "Executing: $CMD"
#$CMD |./splayer_dump.py
$CMD >/dev/null

#echo "Executing: $CMD_FEM_b"
#$CMD_FEM_b |./splayer_dump.py

#Start sequencer without data output
CMD="$IRSCAN 2FF00000"
#echo "Executing: $CMD"
#$CMD |./splayer_dump.py
