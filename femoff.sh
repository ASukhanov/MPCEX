#!/bin/bash
# Deactivate FEMs

# FEMa
Play_stapl.py i10 50010FC0 > /dev/null

# FEMb
Play_stapl.py i10 50010FC0 -g > /dev/null

