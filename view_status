#!/bin/bash
SP_OPTION=""
USAGE="usage: $0 [a/b]"

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
CMD="Play_stapl.py $SP_OPTION i11 0 i12 0 i14 0 i17 0 i20 0 i21 0 i24 0"
#echo "Executing: $CMD"
$CMD  |./splayer_dump.py
