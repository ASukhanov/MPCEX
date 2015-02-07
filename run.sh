#!/bin/bash
SP_OPTION=""
USAGE="usage: $0 [on/off/1])"

if [ "$#" -lt "1" ]; then echo $USAGE; exit; fi

case "$1" in
  start)
    # Start run with default FEM setup, same as 'setfem a0123 trig'
    CMD="Play_stapl.py $SP_OPTION i10 50032f00 i16 aff00000 i20 0 i21 0"
    Play_stapl.py    i10 500321c0 i16 aff00000 i20 0 i21 0 |./splayer_dump.py
    Play_stapl.py -g i10 500321c0 i16 aff00000 i20 0 i21 0 |./splayer_dump.py
    ;;
  on)
    # enable sequencer with data output enabled
    CMD="Play_stapl.py i16 aff00000 > /dev/null"
    Play_stapl.py    i16 aff00000 > /dev/null
    Play_stapl.py -g i16 aff00000 > /dev/null
    ;;
  off)
    # stop sequencer, disable output
    CMD="Play_stapl.py i16 1ff00000 > /dev/null"
    Play_stapl.py    i16 1ff00000 > /dev/null
    Play_stapl.py -g i16 1ff00000 > /dev/null
    ;;
  1)
    # run sequncer once with output enabled
    CMD="Play_stapl.py i16 cff00000 > /dev/null"
    Play_stapl.py    i16 cff00000 > /dev/null
    Play_stapl.py -g i16 cff00000 > /dev/null
    ;;
  *)
    echo $USAGE
    exit
esac

# the nice 'method' does not work
#$CMD
echo "Executed: $CMD"
