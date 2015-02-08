#!/bin/bash
# Set carriers into CN (channel number) mode

USAGE="usage: $0 [a/b]"

#if [ "$#" -lt "1" ]; then echo $USAGE; exit; fi
case "$1" in
  "b")
    Play_stapl.py -g i1c 1; > /dev/null
    Play_stapl.py -g -c i30 10140 140;
    Play_stapl.py -g i1c 2; > /dev/null
    Play_stapl.py -g -c i30 10140 140;
    Play_stapl.py -g i1c 4; > /dev/null
    Play_stapl.py -g -c i30 10140 140;
    Play_stapl.py -g i1c 8; > /dev/null
    Play_stapl.py -g -c i30 10140 140;
    ;;
  "a")
    Play_stapl.py i1c 1; > /dev/null                                             
    Play_stapl.py -c i30 10140 140; 
    Play_stapl.py i1c 2; > /dev/null
    Play_stapl.py -c i30 10140 140;  
    Play_stapl.py i1c 4; > /dev/null 
    Play_stapl.py -c i30 10140 140;  
    Play_stapl.py i1c 8; > /dev/null
    Play_stapl.py -c i30 10140 140;
    ;;
  *)
    Play_stapl.py i1c 1; > /dev/null
    Play_stapl.py -c i30 10140 140;
    Play_stapl.py i1c 2; > /dev/null
    Play_stapl.py -c i30 10140 140;
    Play_stapl.py i1c 4; > /dev/null
    Play_stapl.py -c i30 10140 140;
    Play_stapl.py i1c 8; > /dev/null
    Play_stapl.py -c i30 10140 140;
    Play_stapl.py -g i1c 1; > /dev/null
    Play_stapl.py -g -c i30 10140 140;
    Play_stapl.py -g i1c 2; > /dev/null
    Play_stapl.py -g -c i30 10140 140;
    Play_stapl.py -g i1c 4; > /dev/null
    Play_stapl.py -g -c i30 10140 140;
    Play_stapl.py -g i1c 8; > /dev/null
    Play_stapl.py -g -c i30 10140 140;
esac

