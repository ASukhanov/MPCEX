#!/bin/bash
# Configure Carrier Board
USAGE="usage: $0 a/b0:3 hex_value1 hex_value2, \ni.e. to reset counters on a: for i in 0 1 2 3; do $0 a\$i 10000 0 ; done;"

MASK=1
SP_OPTION=""

if [ "$#" -lt "2" ]; then echo -e $USAGE; exit; fi
VALUE=$2

VALUE2=""
if [ "$#" -ge "3" ]; then VALUE2=$3; fi

CMD=""
case "${1:0:1}" in
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

MASK=${1:1:2}
if [ "$MASK" -gt "3" ]; then echo "ERROR. Carrier board number > 3"; exit; fi

MASK=$((1<<$MASK))

CMD="Play_stapl.py $SP_OPTION i1c $MASK;"
echo "Executing: $CMD"
$CMD > /dev/null
CMD="Play_stapl.py -c $SP_OPTION i30 $VALUE $VALUE2 i32 0"
# |./splayer_dump.py"
echo "Executing: $CMD"
$CMD > /dev/null
