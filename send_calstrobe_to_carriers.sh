#!/bin/bash
# Send Calstrobe to carrier boards to copy the configuration into a SEU-safe shadow register
USAGE="usage: $0 [a/b]"

CMD="i16 1ff00000 40 00120000 00200000 1ff00000 4ff00000"
echo "Executing Play_stapl.py $CMD"
#if [ "$#" -lt "1" ]; then echo $USAGE; exit; fi
case "$1" in
  "b")
    Play_stapl.py -g $CMD 
    ;;
  "a")
    Play_stapl.py $CMD 
    ;;
  *)
    Play_stapl.py $CMD 
    Play_stapl.py -g $CMD 
esac
