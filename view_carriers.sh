#!/bin/bash
# Print CSR of the cartrier boards
SP_OPTION=""
USAGE="usage: $0 [a/b] [on/off/1])"

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

Play_stapl.py $SP_OPTION i1c 1 > /dev/null; # carrier a0
Play_stapl.py $SP_OPTION -c i32 0 i33 0;
Play_stapl.py $SP_OPTION i1c 2 > /dev/null; # carrier a1
Play_stapl.py $SP_OPTION -c i32 0 i33 0;
Play_stapl.py $SP_OPTION i1c 4 > /dev/null; # carrier a2
Play_stapl.py $SP_OPTION -c i32 0 i33 0;
Play_stapl.py $SP_OPTION i1c 8 > /dev/null; # carrier a3
Play_stapl.py $SP_OPTION-c i32 0  i33 0;

