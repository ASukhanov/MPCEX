#!/bin/bash
# Run for one event on FEM, prepare for dump and chipscop it
SP_OPTION=""
USAGE="usage: $0 [a/b]"

if [ "$#" -lt "1" ]; then echo $USAGE; exit; fi

case "$1" in
  "b")
    echo "^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ $HOSTNAME.b ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^"
    SP_OPTION="-g"
    ;;
  "a")
    echo "^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ $HOSTNAME.a ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^"
     SP_OPTION=""
    ;;
  *)
    echo $USAGE
    exit
esac
#default CSR10:
CSR10=0011fc8
# Set to system clock, stop sequencer, this is very important!
#Play_stapl.py i10 50011fc0 i16 aff00000
# download SVXs on all carriers
./svx_conf_enable.sh $1
./svx_download.sh $1
./svx_conf_disable.sh $1
#Play_stapl.py $SP_OPTION i10 5$CSR10 > /dev/null
./view_status.sh $1
# sequencer is stopped, clock is internal, it is safe to setup sequencer for normal running
./sequencer.sh $1 trig > /dev/null
# set carriers into channel number mode, that can be done at any time (when sequencer is off)
#./set_carriers_mode_cn.sh $1
# set required clock and other CSR10 setting 
# and start sequencer
Play_stapl.py $SP_OPTION i10 5$CSR10 i16 aff00000 i1e 10 00 > /dev/null
# sequencer started, ready for one shot
CMD="Play_stapl.py $SP_OPTION i10 5$CSR10 7$CSR10"
echo "Executing $CMD"
$CMD > /dev/null
./view_status.sh $1
$CMD > /dev/null
./view_status.sh $1
echo "to dump: ./dump_event.sh $1"
echo "to chipskop: ./plot_chipskop.pl"
echo "for another one shot: Play_stapl.py $SP_OPTION i10 5$CSR10 7$CSR10 > /dev/null; ./view_status.sh $1"
echo "___________________________________________________________________________"

