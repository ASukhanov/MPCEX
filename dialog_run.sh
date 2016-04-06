#!/bin/bash
# while-menu-dialog: run control of the FEM

DIALOG_CANCEL=1
DIALOG_ESC=255
HEIGHT=0
WIDTH=0

# defaults
FEM="a"
CAR="0" #default carrier
#CAR="" #all
#GEN_MODE="random"
GEN_MODE="en"
GEN_PERIOD="12"	# generator period
DAQ="OFF"

display_result() {
  dialog --title "$1" \
    --no-collapse \
    --msgbox "$result" 0 0
}

dialog_pause() {
  dialog --title "Pause/Continue" \
    --no-collapse \
    --msgbox "DAQ $DAQ" 0 0
}


while true; do
  exec 3>&1
  selection=$(dialog \
    --backtitle "Run Control" \
    --title "Menu" \
    --clear \
    --cancel-label "Exit" \
    --menu "Please select:" $HEIGHT $WIDTH 5 \
    "s" "Start" \
    "o" "Stop" \
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
  case $selection in
    0 )
      clear
      echo "Program terminated."
      ;;
    s )
      result=$(./femon.sh $FEM; ./gtm_lkl.sh $FEM -p$GEN_PERIOD -g$GEN_MODE;)
      display_result "Local generator $GEN_MODE started"
      ;;
    o )
      result=$(./gtm_lkl.sh $FEM -gstop; ./femoff.sh)
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
  esac
done
