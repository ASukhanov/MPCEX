#!/bin/bash
# Enable/Disable carrier boards for configuration

USAGE="usage: $0 a/b enable/disable"

if [ "$#" -lt "2" ]; then echo $USAGE; exit; fi
case "$1" in
  "b"|"-g") 
    SP_OPTION="-g"
    ;;
  "a")
    SP_OPTION="" 
    ;;
  *)  
    echo $USAGE
    exit
    ;;  
esac  
case "$2" in
  "enable") 
    echo "$HOSTNAME.$1: Enabling configuration"
    CMD="Play_stapl.py $SP_OPTION -c i30 100"
   ;;
  "disable")
    echo "$HOSTNAME.$1: Disabling configuration"
    CMD="Play_stapl.py $SP_OPTION -c i30 000"
    ;;
  *)  
    echo $USAGE
    exit
    ;;  
esac  
echo "Executing $CMD on all carriers"

    Play_stapl.py $SP_OPTION i1c 1 > /dev/null
    $CMD > /dev/null
    Play_stapl.py $SP_OPTION i1c 2 > /dev/null
    $CMD > /dev/null
    Play_stapl.py $SP_OPTION i1c 4 > /dev/null
    $CMD > /dev/null
    Play_stapl.py $SP_OPTION i1c 8 > /dev/null
    $CMD > /dev/null
    # disable route to carrier
    Play_stapl.py $SP_OPTION i1c 0 > /dev/null
