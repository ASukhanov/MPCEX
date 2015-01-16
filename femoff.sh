#!/bin/bash
# Deactivate FEMs

# FEMa
Play_stapl.py i10 10000000 > /dev/null

# FEMb
Play_stapl.py i10 10000000 -g > /dev/null

