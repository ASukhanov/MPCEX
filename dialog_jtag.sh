#!/bin/bash
# while-menu-dialog: FPGA info/configuration of the FEM or Carrier board

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

display_result() {
  dialog --title "$1" \
    --no-collapse \
    --msgbox "$result" 0 0
}

while true; do
  exec 3>&1
  selection=$(dialog \
    --backtitle "JTAG" \
    --title "Menu" \
    --clear \
    --cancel-label "Exit" \
    --menu "Please select:" $HEIGHT $WIDTH 4 \
    "1" "FEM Device Info" \
    "2" "Flash FEM" \
    "3" "Carrier Device Info" \
    "4" "Flash Carrier" \
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
    1 )
      result=$(./jtag_flash.sh $FEM)
      display_result "FEM Device Info"
      ;;
    2 )
      result=$(./jtag_flash.sh $FEM program)
      display_result "Flash FEM"
      ;;
    3 )
      result=$(./jtag_flash_carrier.sh $FEM$CAR)
      display_result "Carrier $FEM$CAR Device Info"
      ;;
    4 )
      result=$(./jtag_flash_carrier.sh $FEM$CAR)
      display_result "Flash Carrier $FEM$CAR"
      ;;
  esac
done
