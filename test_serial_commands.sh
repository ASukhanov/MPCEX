#!/bin/bash
VERB="0"
usage()
{
cat << EOF
usage: $0 a/b[i] options

Test serial commands on carrier board (firmware v104+)

OPTIONS:
  -v N  verbosity, 0:3, default:$VERB

EXAMPLES:
$0 b3
EOF
}

if [ "$#" -lt "1" ]; then usage; exit 1; fi

case "${1:0:1}" in
  "b"|"-g")
    FEM="-g"
    ;;
  "a")
    FEM=""
    ;;
  *)
    usage
    exit 1
    ;;
esac

OPTIND=2        # skip first argument
while getopts "v:" opt; do
  #echo "opt=$opt"
  case $opt in
    v)
      VERB=$OPTARG
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
    :)
      echo "Option -$OPTARG requires an argument." >&2
      exit 1
  esac
done


if [ ${#1} -gt "2" ]; then usage; exit 1; fi
if [ ${#1} -eq "2" ]; then
case "${1:1:1}" in
  "0"|"1"|"2"|"3")
    CB="${1:1:1}"
    let "SM = 1<<$CB"
    ;;
  *) echo "carrier board id should be a0 through b3"; exit 1;;
esac
else usage; exit 1;
fi
if [ $VERB -ge "2" ]; then echo "CB=$CB, Select mask = $SM"; fi

CMD="Play_stapl.py $FEM i10 00010${SM:0:1}${CB:0:1}0"
if [ $VERB -ge "2" ]; then echo "executing: $CMD"; fi
eval "$CMD > /dev/null"

CMD="Play_stapl.py $FEM i1c $SM"
if [ $VERB -ge "2" ]; then echo "executing: $CMD"; fi
eval "$CMD > /dev/null"

GNERR=0
#for BIT in 01 02 04 08 10 20 40 80 03 06 0C 30 60 c0 A0 E0 30 28 20 B0 A8 B8 18; do
for BIT in A0 E0 30 28 20 B0 A8 B8 18; do # L1, PARst, Dig, PR2, FEClk, L1+Dig, L1+PR2, L1+Dig+PR2 FECLK-FEMODE
#for BIT in B0; do 
#for BIT in 00 A8; do
  NERR=0

  CMD="Play_stapl.py $FEM i16 1ff00000 000000$BIT 00120000 AFF00000" #load sequencer with single command and start it
  if [ $VERB -ge "2" ]; then echo "executing: $CMD"; fi
  if [ $VERB -ge "1" ]; then echo "pattern $BIT loaded, check 32 times:";fi
  eval "$CMD > /dev/null"
  CMD="Play_stapl.py $FEM i10 00010${SM:0:1}${CB:0:1}0" # reset carriers, set trigger and clock sources
  if [ $VERB -ge "2" ]; then echo "executing: $CMD"; fi
  eval "$CMD > /dev/null"

  # The following is not necessary as sequencer is running permanently
  #if [ $VERB -ge "2" ]; then echo executing: StaplPlayer $FEM -aTrans one_sequencer_cycle.stp; fi
  #StaplPlayer $FEM -aTrans one_sequencer_cycle.stp # > /dev/null;

  printf "${BIT}= "
  # need lastpipe bash option, othervise the following subshell will not change the variables
  shopt -s lastpipe
  Play_stapl.py $FEM -c i32 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 |
  {
    while read line
    do
      STR=${line#*value = }
      if [ "${STR:0:3}" == "HEX" ]; then
        printf "${STR:5:2}"
        if [ "${STR:5:2}" != $BIT ]; then let "NERR = NERR + 1"; printf "?"; else printf ","; fi
      fi
    done
  }
  if [ $NERR -eq "0" ]; then printf "\nOK\n"
  else printf "\n$NERR Errors!\n"; fi
  let "GNERR = GNERR + NERR"
  #sleep 5
done
if [ $GNERR -gt "0" ]; then echo "ERRORS detected: $GNERR"; fi
