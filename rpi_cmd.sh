#!/bin/bash
usage()
{
cat << EOF
usage: $0 n/s "Shell Commands" OPTIONS

Execute the Shell Commands on all north or south Raspberry Pi's
When no options provided:  send CalStrobe to carriers to reset the Cell IDs

OPTIONS
  -d HomeDir	# home direcory of the RPi, default ~/work/MPCEX

EXAMPLES:
$0 s "./view_carriers.sh a;" # check carriers on all south FEMa's
$0 s "./view_status.sh b;" # check all all south FEMb's
$0 n "./jtag_flash_carrier.sh a0 -f /phenixhome/phnxrc/MPCEXFinal/CARB_U1-r14A.stp -p" # flash carrier na0 with new firmware file
$0 n "git pull" # update scripts on mpcexn0,1,2,3 from the github

EOF
}
#V1 Version 1 2015-12-09

HOMEDIR=~/work/MPCEX
NORTH_SOUTH="n"

case "${1}" in
  "n") NORTH_SOUTH="n";;
  "s") NORTH_SOUTH="s";;
  *) usage; exit;;
esac

while getopts "d:" opt; do
  case $opt in
    d) HOMEDIR=$OPTARG;;
    \?) echo "Invalid option: -$OPTARG" >&2; exit 1;;
    :)  echo "Option -$OPTARG requires an argument." >&2; exit 1
esac
done

CMD="for ii in 0 1 2 3; do ssh mpcex$NORTH_SOUTH\$ii 'cd $HOMEDIR; $2'; done"
echo "executing: $CMD"
eval $CMD
