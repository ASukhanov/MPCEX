#!/bin/bash
# Print CSR of the cartrier boards
SP_OPTION=""
USAGE="usage: $0 [a/b]"

case "$1" in
  "b")
    #SP_OPTION="-g"
    Play_stapl.py -g i1c 1 > /dev/null; # carrier a0
    Play_stapl.py -g -c i32 0 i33 0;
    Play_stapl.py -g i1c 2 > /dev/null; # carrier a1
    Play_stapl.py -g -c i32 0 i33 0;
    Play_stapl.py -g i1c 4 > /dev/null; # carrier a2
    Play_stapl.py -g -c i32 0 i33 0;
    Play_stapl.py -g i1c 8 > /dev/null; # carrier a3
    Play_stapl.py -g -c i32 0  i33 0;
    ;;
  "a")
    #SP_OPTION=""
    Play_stapl.py i1c 1 > /dev/null; # carrier a0
    Play_stapl.py -c i32 0 i33 0;
    Play_stapl.py i1c 2 > /dev/null; # carrier a1
    Play_stapl.py -c i32 0 i33 0;
    Play_stapl.py i1c 4 > /dev/null; # carrier a2
    Play_stapl.py -c i32 0 i33 0;
    Play_stapl.py i1c 8 > /dev/null; # carrier a3
    ;;
  *)
    Play_stapl.py -g i1c 1 > /dev/null; # carrier a0
    Play_stapl.py -g -c i32 0 i33 0;
    Play_stapl.py -g i1c 2 > /dev/null; # carrier a1
    Play_stapl.py -g -c i32 0 i33 0;
    Play_stapl.py -g i1c 4 > /dev/null; # carrier a2
    Play_stapl.py -g -c i32 0 i33 0;
    Play_stapl.py -g i1c 8 > /dev/null; # carrier a3
    Play_stapl.py -g -c i32 0  i33 0;
    Play_stapl.py i1c 1 > /dev/null; # carrier a0
    Play_stapl.py -c i32 0 i33 0;
    Play_stapl.py i1c 2 > /dev/null; # carrier a1
    Play_stapl.py -c i32 0 i33 0;
    Play_stapl.py i1c 4 > /dev/null; # carrier a2
    Play_stapl.py -c i32 0 i33 0;
    Play_stapl.py i1c 8 > /dev/null; # carrier a3
esac
