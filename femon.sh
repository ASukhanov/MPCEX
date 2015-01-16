#!/bin/bash
# Activate FEMs

# FEMTest mode, internal clock
CSR10=50101F04

# FEMTest mode, beam clock
#CSR10=50101F0C

# Setup FEM and start sequencer on FEMa
Play_stapl.py i10 $CSR10 i16 aff00000 > /dev/null

# and on FEMb
Play_stapl.py i10 $CSR10 i16 aff00000 -g > /dev/null
