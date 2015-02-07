#!/bin/bash
SP_OPTION=""
USAGE="usage: $0 [a/b]"
if [ "$#" -lt "1" ]; then echo $USAGE; exit; fi
case "$1" in
  "b")
    SP_OPTION="-g"
    ;;
  "a")
     SP_OPTION=""
    ;;
  *)
    echo $USAGE
esac
echo "Executing: Play_stapl.py $SP_OPTION i16 1ff00000 40 00120000 00200000 1ff00000 4ff00000"
Play_stapl.py $SP_OPTION i16 1ff00000 40 00120000 00200000 1ff00000 4ff00000 > /dev/null
