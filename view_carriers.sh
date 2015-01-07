#!/bin/bash
# Print CSR of the cartrier boards
Play_stapl.py i1c 1 > /dev/null; # carrier a0
Play_stapl.py -c i32 0;
Play_stapl.py i1c 2 > /dev/null; # carrier a1
Play_stapl.py -c i32 0;
Play_stapl.py i1c 4 > /dev/null; # carrier a2
Play_stapl.py -c i32 0;
Play_stapl.py i1c 8 > /dev/null; # carrier a3
Play_stapl.py -c i32 0;
Play_stapl.py -g i1c 1 > /dev/null; # carrier b0
Play_stapl.py -g -c i32 0;
Play_stapl.py -g i1c 2 > /dev/null; # carrier b1
Play_stapl.py -g -c i32 0;
Play_stapl.py -g i1c 4 > /dev/null; # carrier b2
Play_stapl.py -g -c i32 0;
Play_stapl.py -g i1c 8 > /dev/null; # carrier b3
Play_stapl.py -g -c i32 0;

