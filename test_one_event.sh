#!/bin/bash
usage ()
{
cat << EOF
usage: $0 a/b[m]

Run for one local event on FEM a or b, using chain m as master

EOF
}
#'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
# defaults:
#default CSR10:
# Set system clock, stop sequencer, this is very important!
let "CSR10=16#0011fc8"	# all carriers enabled
#let "CSR10=16#0011C28"	# only B2 and B3 are enabled, B2 is master

SP_OPTION=""
CB="0"
FEM="a"
BYPASS=""	# default, all enabled
#BYPASS="-b 001110"	# positions 2,3,4 bypassed
SVXFILE="-f svx6.stp"	# default file
#SVXFILE="-f svx3.stp"
#,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,
#'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

if [ "$#" -lt "1" ]; then usage; exit 1; fi

# FEM
case "${1:0:1}" in
  "b")
    SP_OPTION="-g"
    FEM="b"
    ;;
  "a")
     SP_OPTION=""
    ;;
  *)
    echo $USAGE
    exit
esac
echo "''''''''''''''''''''''''''''''' $HOSTNAME.$FEM '''''''''''''''''''''''''''''''"

# Master chain
case "${1:1:1}" in
  "0"|"1"|"2"|"3")
    CB="${1:1:1}"
    let "CSR10 = $CSR10 | (($CB&3)<<4)"
    ;;
esac
CSR10=`printf "%07x\n" $CSR10`
#echo $CSR10; exit

#Play_stapl.py i10 50011fc0 i16 aff00000
# download SVXs on all carriers
./carrier_config.sh $FEM $BYPASS -d #-v	# enable downloading, FEMODE = 0
./svx_download.sh $FEM $SVXFILE -v 0	# download all carriers
./send_calstrobe_to_carrier.sh $FEM	# latch the configuration and reset cell numbers
./carrier_config.sh $FEM $BYPASS       # disable downloading, FEMODE = 1

#Play_stapl.py $SP_OPTION i10 5$CSR10 > /dev/null
./view_status.sh $FEM -s 0 > /dev/null	# force to send all events
# sequencer is stopped, clock is internal, it is safe to setup sequencer for normal running
# not necessary: ./sequencer.sh $FEM trig
# set carriers into channel number mode, that can be done at any time (when sequencer is off)
#./set_carriers_mode_cn.sh $FEM
# set required clock and other CSR10 setting
# and start sequencer
CMD="Play_stapl.py $SP_OPTION i10 5$CSR10 i16 aff00000 i1e 10 00"
#echo "Executing $CMD"
eval $CMD > /dev/null
#./view_status.sh $FEM -s 0
# sequencer started, ready for one shot
CMD="Play_stapl.py $SP_OPTION i10 5$CSR10 7$CSR10"
#echo "Executing $CMD"
eval $CMD > /dev/null
#./view_status.sh $FEM -s 0
eval $CMD > /dev/null
./view_status.sh $FEM -s 0
#echo "to dump: ./dump_event.sh $FEM"
#echo "to chipskop: ./plot_chipskop.pl"
#echo "for another one shot: Play_stapl.py $SP_OPTION i10 5$CSR10 7$CSR10 > /dev/null; ./view_status.sh $FEM"
echo ",,,,,,,,,,,,,,,,,,,,,,,,,,,,,,, $HOSTNAME.$FEM ,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,"
