#!/bin/bash
# The main set of command after re-flashing the FEM
#./onReboot.sh;
#./sequencer.sh b trig;
./gtm_lkl.sh a -gst;
./femoff.sh a; sleep 1
./femon.sh a -s1 -v5;
./view_status.sh a -v5 -s1
#./carrier_config.sh a -n;
#./carrier_config.sh a -s12;
#Play_stapl.py i10 00001218;
./view_carriers.sh a
./gtm_lkl.sh a -t1 -p15 -i27 -gen;
for ii in {1..10}; do ./view_status.sh a -v5 -s1; done
./gtm_lkl.sh a -gst;
./view_carriers.sh a

