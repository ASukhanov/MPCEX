#!/bin/bash
# while-menu-dialog: run control of the FEM

# defaults
FEM="a"
CAR="0" #default carrier
#CAR="" #all

#GEN_MODE="random" # pseudo random generator
GEN_MODE="en"   # periodic generator

GEN_PERIOD="15"  # Log2 of generator period, 1: 18KHz, 2: 9KHz

XTRIG="-x -t0"	# enable external trigger and disable internal triggers

CAPLOG="-v"	# extended logging of data capture

BIAS="100"       # Bias level [V]
BIAS_STANDBY="50" # Bias standby level [V]
#BIAS="50"	# Bias level [V]
#BIAS_STANDBY="25" # Bias standby level [V]

#FEMFAKE="-f" # Test FEM data transfer with fake data

DIALOG_CANCEL=1
DIALOG_ESC=255
HEIGHT=0
WIDTH=0
DAQ="OFF"
RUN="stopped"

display_result() {
  dialog --title "$1" \
    --no-collapse \
    --msgbox "$result $comment" 0 0
}

dialog_pause() {
  dialog --title "Pause/Continue" \
    --no-collapse \
    --msgbox "DAQ $DAQ" 0 0
}


while true; do
  exec 3>&1
  selection=$(dialog \
    --backtitle "Silicon Strips Run Control" \
    --title "Menu" \
    --clear \
    --cancel-label "Exit" \
    --menu "Please select:" $HEIGHT $WIDTH 5 \
    "s" "Start" \
    "o" "Stop" \
    "e" "Capture data on the ethernet port" \
    "ew1" "Capture and write data to file system 1"\
    "ew2" "Capture and write data to file system 2"\
    "ef" "Finish data capture"\
    "b" "Turn on Bias"\
    "bs" "Set Bias to Standby"\
    "bf" "Turn off Bias"\
    "p" "Pause/Continue" \
    "f" "View FEM Status" \
    "c" "View Carrier Status" \
    "d" "Download Configuration to Carriers" \
    2>&1 1>&3)
  exit_status=$?
  exec 3>&-
  case $exit_status in
    $DIALOG_CANCEL)
      clear
      echo "Program terminated."
      exit
      ;;
    $DIALOG_ESC)
      clear
      echo "Program aborted." >&2
      exit 1
      ;;
  esac
  comment=""
  case $selection in
    0 )
      clear
      echo "Program terminated."
      ;;
    s )
      if [ $RUN == "started" ]
        then
          result="Run is already started"
          display_result "Run is already started";
        else
          result=$(./femon.sh $FEM $FEMFAKE; ./gtm_lkl.sh $FEM -p$GEN_PERIOD $XTRIG -g$GEN_MODE;)
          display_result "Local generator $GEN_MODE started"
          RUN="started"
        fi
      ;;
    o )
      result=$(./gtm_lkl.sh $FEM -gstop; ./femoff.sh)
      RUN="stopped"
      display_result "Run stopped"
      ;;
    p )
      if [ $DAQ == "ON" ];
        then DAQ="OFF"; ./gtm_lkl.sh $FEM -gstop;
        else DAQ="ON"; ./gtm_lkl.sh $FEM -p$GEN_PERIOD -g$GEN_MODE;
      fi
      #dialog_pause=$(echo "DAQ #DAQ")
      display_result "DAQ $DAQ"
      ;;
    f )
      result=$(./view_status.sh $FEM)
      display_result "FEM status"
      ;;
    c )
      result=$(./view_carriers.sh $FEM$CAR)
      display_result "Carrier status"
      ;;
    d )
      result=$(./doall.sh $FEM)
      display_result "Downloading Carriers of FEM$FEM"
      ;;
    e )
      result=$(script -q -c "~/work/MPCEX/dqc.py $CAPLOG" /dev/null > /tmp/dqc.log&)
      comment="To watch capture progress: tail -f /tmp/dqc.log"
      display_result "Capture data on ethernet port                    "
      ;;
    ew1 )
      result=$(script -q -c "~/work/MPCEX/dqc.py -w1 $CAPLOG" /dev/null > /tmp/dqc.log&)
      comment="To watch capture progress: tail -f /tmp/dqc.log"
      display_result "Capture and write data to file system 1          "
      ;;
    ew2 )
      result=$(script -q -c "~/work/MPCEX/dqc.py -w2 $CAPLOG" /dev/null > /tmp/dqc.log&)
      comment="To watch capture progress: tail -f /tmp/dqc.log"
      display_result "Capture and write data to /tmp                   "
      ;;
    ef )
      result=$(killall dqc.py)
      display_result "Stop data capture"
      ;;
    b )
      result=$( ~/work/spi/dadc_set_bias.sh $BIAS)
      display_result "Bias On                       "
      ;;
    bs )
      result=$( ~/work/spi/dadc_set_bias.sh $BIAS_STANDBY)
      display_result "Bias Standby                  "
      ;;
    bf )
      result=$( ~/work/spi/dadc_set_bias.sh 0)
      display_result "Bias Off"
      ;;
  esac
done
