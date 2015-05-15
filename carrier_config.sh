#!/bin/bash
usage ()
{
cat << EOF
usage: $0 [a/b][i] cn/sim/bypass/reset mask options

Reconfigure carrier boards.

OPTIONS:
  -d Drop FEMode on SVXs, this will enable for further downloading
  -n Channel Number mode
  -s N	Simulate N SVx4
  -b M  Bypass modules, M is the binary bypassing mask
  -v Verbose
  -p P	Probe. Connect one of the signals to SDI line for probing on FEM.

EXAMPLES:
$0 b3 -b 011111 -d:
on carrier b3 bypass all modules except 6, enable for downloading
$0 b3 -b 101100 -n:
on carrier b3 bypass modules 6,4,3, disable the downloading and set CN mode
$0 a -s 12: 	set all carriers of FEM.a for generating fake data of 12 SVXs"
$0 b		default configuration of all carriers of FEM.b, ready for data taking
EOF
}
probing ()
{
case $PROBE in
15) SIGNAL="BEMode";;
14) SIGNAL="PRD2";;
13) SIGNAL="PARst";;
12) SIGNAL="DClk";;
11) SIGNAL="Bus0";;
10) SIGNAL="BDClk";;
9) SIGNAL="SDO+BClkEn";;
8) SIGNAL="FEClk";;
7) SIGNAL="LPrOut";;
6) SIGNAL="FEMode";;
5) SIGNAL="Bus0R";;
4) SIGNAL="D0";;
3) SIGNAL="OBDV";;
2) SIGNAL="BEClk";;
1) SIGNAL="PrIn";;
0) SIGNAL="L0";;
*) echo ERROR. Wrong -p argument, should be 0 through 15; exit 1;;
esac
echo "Signal $SIGNAL is connected to probing line SIN"
}

# defaults:
let "i30 = 16#00000000"
MASK="0"
let "OPEN_CONF = 16#000"	# FEMODE = 0
let "MASTER = 16#F"
VERB="0"
CB="0,1,2,3"
PROBE="0"

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
    usage
    exit 1
    ;;
esac

if [ ${#1} -gt "2" ]; then usage; exit 1; fi
if [ ${#1} -eq "2" ]; then
case "${1:1:1}" in
  "0"|"1"|"2"|"3")
    CB="${1:1:1}"
    let "MASTER = 1<<$CB"
    ;;
  *) echo "carrier board id should be a0 through b3"; exit 1;;
esac
fi
#let "MASTER = 1<<$CB"
#echo "CB=$CB, Master=$MASTER"

OPTIND=2        # skip commands
while getopts ":dns:b:vp:" opt; do
  #echo "opt=$opt"
  case $opt in
    d)  let "i30 = $i30 | 16#100";;	# drop FEMODE
    n)	let "i30 = $i30 | 16#40";;	# Channel Number mode
    s)	let "i30 = $i30&(~16#3F) | 16#80 | $OPTARG&16#3F";;	# simulate number of SVXs
    b)	let "i30 = $i30 | (2#$OPTARG)&16#3F";;		# bypass modules
    v)	VERB="1";;
    p)  let "i30 = $i30 | (($OPTARG)&16#3F)<<12"; PROBE=$OPTARG; probing;;
    :)	echo "ERROR, Option argument is required"; exit 1;;
    ?)	echo "ERROR, Illegal option"; exit 1;;
    *)	;;
  esac
done

#printf "MASK=%02x\n" $MASK
#let "i30 = $i30 | ($MASK&16#3F)"
#let "i30 = $i30 | OPEN_CONF"		# correct way to deal with open/close

HEXNUM=`printf "%08x\n" $i30`
MASTER=`printf "%08x\n" $MASTER`

if (($i30 & 16#100)); then DOWNLOADING="enabled"; else DOWNLOADING="disabled"; fi
printf "carrier.config: Downloading is $DOWNLOADING on FEM.${1:0:1}[$CB]\n"
if [ $i30 -eq "0" ]; then printf "carrier.config: Default configurarion on FEM.${1:0:1}[$CB]\n"; fi

#printf "setting i30=%08x\n" $i30

CMD="Play_stapl.py $FEM  i1c $MASTER" # set path to CB
if [ $VERB -eq "1" ]; then echo "executing: $CMD"; fi
eval $CMD > /dev/null
CMD="Play_stapl.py $FEM -c i30 $HEXNUM"
if [ $VERB -eq "1" ]; then echo "executing: $CMD"; fi
eval $CMD > /dev/null
