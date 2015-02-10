#!/bin/bash
# Deactivate FEMs

# FEMa
Play_stapl.py i10 10010FC0 > /dev/null

# FEMb
Play_stapl.py i10 10010FC0 -g > /dev/null

