#!/bin/bash
usage ()
{
cat << EOF
usage: $0 [a/b][i] cn/sim/bypass/reset mask options

Configure carrier board.

OPTIONS:
  -d Drop FEMode on SVXs, this will enable for further downloading
  -n Channel Number mode
  -s N	Simulate N SVx4
  -b M  Bypass modules, M is the binary bypassing mask
  -v Verbose

EXAMPLES:
$0 b3 -b 11111 -d:
on carrier b3 bypass all modules except 6, enable for downloading
$0 b3 -b 101100 -n:
on carrier b3 bypass modules 6,4,3, disable the downloading and set CN mode
$0 a -s 12: 	set all carriers of FEM.a for generating fake data of 12 SVXs"
$0 b		default configuration of all carriers of FEM.b, ready for data taking
EOF
}

# defaults:
let "i30 = 16#00000000"
MASK="0"
let "OPEN_CONF = 16#000"	# FEMODE = 0
let "MASTER = 16#F"
VERB="0"

#echo $#
if [ "$#" -lt "1" ]; then usage; exit 1; fi

case "${1:0:1}" in
  "b"|"-g")
    FEM="-g"
    ;;
  "a")
    FEM=""
    ;;
  *)
    echo $USAGE
    exit
    ;;
esac
 
#echo ${1:1:1}
case "${1:1:1}" in
  "0"|"1"|"2"|"3")
    CB="${1:1:1}"
    let "MASTER = 1<<$CB"
    ;;
  *)
    #echo "carrier board id should be a0 through b3"; exit 1
    if [ $VERB -eq "1" ]; then echo "Configuring all carriers of FEM.$1"; fi
    ;;
esac
#let "MASTER = 1<<$CB"
#echo "CB=$CB, Master=$MASTER"

OPTIND=2        # skip commands
while getopts ":dns:b:v" opt; do
  #echo "opt=$opt"
  case $opt in
    d)  # enable for downloading
      let "OPEN_CONF = 16#100"	# drop FEMODE
      ;;
    n)	# Channel Number mode
      let "i30 = $i30 | 16#40"
      ;;
    s)	# simulate number of SVXs
      let "i30 = $i30 | 16#80"
      let "MASK = $OPTARG"
      ;;
    b)	# bypass modules
      let "MASK = 2#$OPTARG"
      ;;
    v)
      VERB="1"
      ;;
    :)
      echo "ERROR, Option argument is required"
      exit 1
      ;;
    ?)
      echo "ERROR, Illegal option"
      exit 1
      ;;
    *)
      ;;
  esac
done

#printf "MASK=%02x\n" $MASK
let "i30 = $i30 | ($MASK&16#3F)"
let "i30 = $i30 | OPEN_CONF"		# correct way to deal with open/close

HEXNUM=`printf "%08x\n" $i30`
if (($i30 & 16#100)); then printf "carrier.config: Downloading enabled\n"; fi
if [ $i30 -eq "0" ]; then printf "carrier.config: Default configurarion\n"; fi

#printf "setting i30=%08x\n" $i30

MASTER=`printf "%08x\n" $MASTER`
CMD="Play_stapl.py $FEM  i1c $MASTER" # set path to CB
if [ $VERB -eq "1" ]; then echo "executing: $CMD"; fi
eval $CMD > /dev/null
CMD="Play_stapl.py $FEM -c i30 $HEXNUM"
if [ $VERB -eq "1" ]; then echo "executing: $CMD"; fi
eval $CMD > /dev/null
