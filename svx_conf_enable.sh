#!/bin/bash
# Enable carrier boards for configuration

USAGE="usage: $0 a/b"

#if [ "$#" -lt "1" ]; then echo $USAGE; exit; fi
case "$1" in
  "b"|"-g")
    echo "Enabling SVX configuration on b0,b1,b2.b3"
    Play_stapl.py -g i1c 1 > /dev/null
    Play_stapl.py -g -c i30 100 > /dev/null
    Play_stapl.py -g i1c 2 > /dev/null
    Play_stapl.py -g -c i30 100 > /dev/null
    Play_stapl.py -g i1c 4 > /dev/null
    Play_stapl.py -g -c i30 100 > /dev/null
    Play_stapl.py -g i1c 8 > /dev/null
    Play_stapl.py -g -c i30 100 > /dev/null
    # disable route to carrier
    Play_stapl.py -g i1c 0 > /dev/null
    ;;
  *)
    echo "Enabling SVX configuration on a0,a1,a2.a3"
    Play_stapl.py i1c 1 > /dev/null
    Play_stapl.py -c i30 100 > /dev/null
    Play_stapl.py i1c 2 > /dev/null
    Play_stapl.py -c i30 100 > /dev/null
    Play_stapl.py i1c 4 > /dev/null
    Play_stapl.py -c i30 100 > /dev/null
    Play_stapl.py i1c 8 > /dev/null
    Play_stapl.py -c i30 100 > /dev/null
    # disable route to carrier
    Play_stapl.py i1c 0 > /dev/null
    ;;
esac
