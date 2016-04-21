#!/bin/bash
# The main set of command after re-flashing the FEM
FEM=a

#./onReboot.sh;
#./sequencer.sh b trig;
./gtm_lkl.sh $FEM -gst;
./femoff.sh $FEM; sleep 1
./femon.sh $FEM -g -s1 -v5;
./view_status.sh $FEM -v5 -s1
##./carrier_config.sh $FEM -n;
##./carrier_config.sh $FEM -s12;
##Play_stapl.py i10 00001218;
./view_carriers.sh $FEM
./gtm_lkl.sh $FEM -t1 -p15 -i27 -gen;
for ii in {1..10}; do ./view_status.sh $FEM -v5 -s1; done
./gtm_lkl.sh $FEM -gst;
./view_carriers.sh $FEM

