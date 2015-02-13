#!/bin/bash
# Set carriers into CN (channel number) mode

USAGE="usage: $0 [a/b]"

#if [ "$#" -lt "1" ]; then echo $USAGE; exit; fi
case "$1" in
  "b")
    echo "Setting carriers on FEMb"
    Play_stapl.py -g i1c 1 > /dev/null
<<<<<<< HEAD
    Play_stapl.py -g -c i30 10100 00 > /dev/null
    Play_stapl.py -g i1c 2 > /dev/null
    Play_stapl.py -g -c i30 10100 00 > /dev/null
    Play_stapl.py -g i1c 4 > /dev/null
    Play_stapl.py -g -c i30 10100 00 > /dev/null
    Play_stapl.py -g i1c 8 > /dev/null
    Play_stapl.py -g -c i30 10100 00 > /dev/null
=======
    Play_stapl.py -g -c i30 10100 100 > /dev/null
    Play_stapl.py -g i1c 2 > /dev/null
    Play_stapl.py -g -c i30 10100 100 > /dev/null
    Play_stapl.py -g i1c 4 > /dev/null
    Play_stapl.py -g -c i30 10100 100 > /dev/null
    Play_stapl.py -g i1c 8 > /dev/null
    Play_stapl.py -g -c i30 10100 100 > /dev/null
>>>>>>> a071f3ae94f8cf99a49c7752b0b181fc0267410a
    ;;
  "a")
    echo "Setting carriers on FEMa"
    Play_stapl.py i1c 1 > /dev/null
<<<<<<< HEAD
    Play_stapl.py -c i30 10100 00 > /dev/null
    Play_stapl.py i1c 2 > /dev/null
    Play_stapl.py -c i30 10100 00 > /dev/null
    Play_stapl.py i1c 4 > /dev/null
    Play_stapl.py -c i30 10100 00 > /dev/null
    Play_stapl.py i1c 8 > /dev/null
    Play_stapl.py -c i30 10100 00 > /dev/null
=======
    Play_stapl.py -c i30 10100 100 > /dev/null
    Play_stapl.py i1c 2 > /dev/null
    Play_stapl.py -c i30 10100 100 > /dev/null
    Play_stapl.py i1c 4 > /dev/null
    Play_stapl.py -c i30 10100 100 > /dev/null
    Play_stapl.py i1c 8 > /dev/null
    Play_stapl.py -c i30 10100 100 > /dev/null
>>>>>>> a071f3ae94f8cf99a49c7752b0b181fc0267410a
    ;;
  *)
    echo "Setting carriers on FEMa and FEMb"
    Play_stapl.py i1c 1 > /dev/null
<<<<<<< HEAD
    Play_stapl.py -c i30 10100 00 > /dev/null
    Play_stapl.py i1c 2 > /dev/null
    Play_stapl.py -c i30 10100 00 > /dev/null
    Play_stapl.py i1c 4 > /dev/null
    Play_stapl.py -c i30 10100 00 > /dev/null
    Play_stapl.py i1c 8 > /dev/null
    Play_stapl.py -c i30 10100 00 > /dev/null
    Play_stapl.py -g i1c 1 > /dev/null
    Play_stapl.py -g -c i30 10100 00 > /dev/null
    Play_stapl.py -g i1c 2 > /dev/null
    Play_stapl.py -g -c i30 10100 00 > /dev/null
    Play_stapl.py -g i1c 4 > /dev/null
    Play_stapl.py -g -c i30 10100 00 > /dev/null
    Play_stapl.py -g i1c 8 > /dev/null
    Play_stapl.py -g -c i30 10100 00 > /dev/null
=======
    Play_stapl.py -c i30 10100 100 > /dev/null
    Play_stapl.py i1c 2 > /dev/null
    Play_stapl.py -c i30 10100 100 > /dev/null
    Play_stapl.py i1c 4 > /dev/null
    Play_stapl.py -c i30 10100 100 > /dev/null
    Play_stapl.py i1c 8 > /dev/null
    Play_stapl.py -c i30 10100 100 > /dev/null
    Play_stapl.py -g i1c 1 > /dev/null
    Play_stapl.py -g -c i30 10100 100 > /dev/null
    Play_stapl.py -g i1c 2 > /dev/null
    Play_stapl.py -g -c i30 10100 100 > /dev/null
    Play_stapl.py -g i1c 4 > /dev/null
    Play_stapl.py -g -c i30 10100 100 > /dev/null
    Play_stapl.py -g i1c 8 > /dev/null
    Play_stapl.py -g -c i30 10100 100 > /dev/null
>>>>>>> a071f3ae94f8cf99a49c7752b0b181fc0267410a
esac

