#!/bin/bash
# Set FEM ID
USAGE="usage: $0 ID. (Defaul ID = 77) "

SP_OPTION=""
ID=77

if [ $# == 0 ]; then echo $USAGE; exit; fi
if [ $1 == "b" ]; then SP_OPTION="-g"; fi
if [ $# == 2 ]; then ID=$2; fi

CMD="Play_stapl.py $SP_OPTION i23 $ID"

echo "Executing: $CMD"
$CMD

