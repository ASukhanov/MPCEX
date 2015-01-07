#!/bin/bash
# Dump 1K words from the shadow FIFO

SP_OPTION=""
USAGE="usage: $0 [a/b]"

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

CMD="StaplPlayer $SP_OPTION -atrans dump_rbfifo-1k.stp"

echo "Executing: $CMD |./splayer_dump.py"
$CMD |./splayer_dump.py
