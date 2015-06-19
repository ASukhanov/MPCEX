#!/bin/bash
usage()
{
cat << EOF
usage: $0 a/b[i] options

test serial commands on carrier board

OPTIONS:

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
#echo "CB=$CB, Select mask = $SM"

#echo executing: Play_stapl.py $FEM i10 50100000 000101${CB:0:1}0
Play_stapl.py $FEM i10 50100000 000101${CB:0:1}0 > /dev/null; # reset carriers, set trigger and clock sources
./carrier_config.sh a -b000000 -d -p9
#echo executing Play_stapl.py $FEM i1c $SM
Play_stapl.py $FEM i1c $SM > /dev/null; # select carrier board 0

#for BIT in 01 02 04 08 10 20 40 80; do
for BIT in 00 18 ff; do
  #echo Play_stapl.py i16 1ff00000 000000$BIT 00120000 AFF00000
  echo load pattern $BIT
  Play_stapl.py $FEM i16 1ff00000 000000$BIT 00120000 AFF00000 > /dev/null; # load sequencer with single command and start it
  #./chipskop.sh a arm_seq 1
  ##./svx_download.sh a -v3 -f svx1.stp
  ##StaplPlayer  -aTrans svx1.stp
  #echo executing: Play_stapl.py $FEM i10 00100000 000101${CB:0:1}0
  Play_stapl.py $FEM i10 00100000 000101${CB:0:1}0 > /dev/null; # reset carriers, set trigger and clock sources
  StaplPlayer $FEM -aTrans dbg_one_sequencer_cycle.stp > /dev/null;
  #./view_carriers.sh a
  #Play_stapl.py  i1c 1
  (Play_stapl.py $FEM -c i32 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0;) | ( # | ./splayer_dump.py
    while read line
    do
      #echo line: $line;
      STR=${line#*value = }
      #echo "$STR"
      if [ "${STR:0:3}" == "HEX" ]; then
        printf "${STR:5:2},"
      fi
    done
    #printf "\n"
  )
  printf "\n"
  #./chipskop.sh a plot
  #SFILE=$(ls -t waveforms/csk_* | head -1)
  ##echo $SFILE
  #scp $SFILE andrey@130.199.23.189:work/MPCEX/waveforms/
done
