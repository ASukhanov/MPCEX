#!/bin/bash
usage()
{
cat << EOF
usage: $0 n/s0/1/2/3 "Shell Commands" OPTIONS

Execute the Shell Commands on a Pi

OPTIONS
  -d HomeDir	# home direcory of the RPi, default ~/work/MPCEX

EXAMPLES:
$0 s "./view_carriers.sh a;" # check carriers on mpcexs0-3
$0 s "./view_status.sh a;" # check all south FEMa 
$0 n "./jtag_flash_carrier.sh a0 -f /phenixhome/phnxrc/MPCEXFinal/CARB_U1-r14A.stp -p" # flash carrier na0 with new firmware file
$0 n "git pull" # update scripts on mpcexn0,1,2,3 from the github

EOF
}

#HOMEDIR=~/work/MPCEX/
HOMEDIR=/phenixhome/phnxrc/MPCEX/

while getopts "d:" opt; do
  case $opt in
    d) HOMEDIR=$OPTARG;;
    \?) echo "Invalid option: -$OPTARG" >&2; exit 1;;
    :)  echo "Option -$OPTARG requires an argument." >&2; exit 1
esac
done

CMD="ssh mpcex$1 'cd $HOMEDIR; $2'"
echo "executing: $CMD"
eval $CMD
