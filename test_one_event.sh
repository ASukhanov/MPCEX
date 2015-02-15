#!/bin/bash
# Run for one event on FEM, prepare for dump and chipscop it
SP_OPTION=""
USAGE="usage: $0 [a/b]"

if [ "$#" -lt "1" ]; then echo $USAGE; exit; fi

case "$1" in
  "b")
    SP_OPTION="-g"
    ;;
  "a")
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
./view_status.sh
# sequencer is stopped and clock source is safely set by now
./sequencer.sh $1 trig > /dev/null
# set carriers into channel number mode
./set_carriers_mode_cn.sh $1
# set required clock and other CSR10 setting 
# and start sequencer
Play_stapl.py $SP_OPTION i10 5$CSR10 i16 aff00000 i1e 10 00 > /dev/null
# sequencer started, ready for one shot
Play_stapl.py $SP_OPTION i10 7$CSR10 > /dev/null
./view_status.sh
echo "to dump: ./dump_event.sh"
echo "to chipskop: ./plot_chipskop.pl"
echo "for another one shot: Play_stapl.py $SP_OPTION i10 5$CSR10 7$CSR10 > /dev/null; ./view_status.sh"
