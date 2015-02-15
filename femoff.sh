#!/bin/bash
# Stop sequencers on FEMs

# FEMa
Play_stapl.py i16 1ff00000 > /dev/null
#Play_stapl.py i10 50010FC0 > /dev/null

# FEMb
Play_stapl.py -g i16 1ff00000 > /dev/null
#Play_stapl.py i10 50010FC0 -g > /dev/null

