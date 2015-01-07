#!/bin/bash
# Control of the FEM on-board logic analyzer

SP_OPTION=""
USAGE="usage: $0 [a/b] [arm/plot]"

CMD=""
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

case "$2" in
  "arm")
     CMD="Play_stapl.py i1e 11 1" # |./splayer_dump.py"
    ;;
  "plot")
     CMD="./plot_chipskop.py"
    ;;
  *)
    echo $USAGE
    exit
esac

echo "Executing: $CMD"
$CMD
# > /dev/null
