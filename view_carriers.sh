#!/bin/bash
usage()
{
cat << EOF
usage: $0 [a/b] options

Print carrier board registers connected to FEMa,b or to both.

OPTIONS:
  -v N  verbosity, default:$VERB

EOF
}
# version v02 2015-12-21: no arguments - show both carriers on FEMs
# version v03 2016-04-01: removed () in command output processing, getopts.

SP_OPTION=""
FEM="a"
VERB=0
#VERB=1
PIPE="> /dev/null"
if [ $VERB -ne "0" ]; then PIPE=""; fi

PSDIR='' # default
#PSDIR="~/work/StaplPlayer/" #for debugging
#echo "GPIO_JTAG1_CS=$GPIO_JTAG1_CS"

process_cmd()
{
echo "''''''''''''''''''''''''''''''' $HOSTNAME$1$FEM '''''''''''''''''''''''''''''''''"
CB=0
for i in 1 2 4 8; do
  CMD="${PSDIR}Play_stapl.py $SP_OPTION i1c $i $PIPE"
  if [ $VERB -ne "0" ]; then echo "Executing $CMD"; fi
  eval $CMD
  REG=0
  CMD="${PSDIR}Play_stapl.py -c $SP_OPTION i32 0 i33 0"
  if [ $VERB -ne "0" ]; then echo "Executing $CMD"; fi
  eval $CMD | \
    while read line
    do
      #echo "line: $line"
      STR=${line#*value = }
      #echo "$STR"
      if [ "${STR:0:3}" == "HEX" ]; then
        #printf "$REG: ${STR:4:8}" 
	if [ $REG -eq "0" ]; then CSR32=${STR:4:8}; fi
        #printf "CB$CB:v=${STR:8:2}:  ${STR:4:8}_" ;fi
        if [ $REG -eq "1" ]; then 
	  CSR33=${STR:4:8};
          printf "CB$CB: $CSR32-$CSR33, vers=${CSR32:4:2} "
          let "i32 = 16#$CSR32"
          #let "FEMODE = ($i32>>18)&1"	# version prior vD1
          let "FEMODE = ($i32>>16)&1"	# version vD1
          let "PROUT = ($i32>>19)&1"
          let "LAST_CMD = ($i32>>20)&16#FF"
          let "CN = ($i32>>6)&1"
          let "SIM = ($i32>>7)&1"
          let "BYPASS = $i32&0x3F"
          let "i33 = 16#$CSR33"
          let "PR2 = ($i33)&16#FFF"
          let "PAR = ($i33>>16)&16#FF"
          let "L0 =  ($i33>>24)&16#FF"
          let "FEClkCnt = ($i32>>28)&0xF"
          let "BEClkCnt = ($i33>>12)&0xF"
          printf "FM=$FEMODE PO=$PROUT CMD=%02x PR2=%03x PAR=%02x L0=%02x FC=%01x BC=%01x " $LAST_CMD $PR2 $PAR $L0 $FEClkCnt $BEClkCnt
          if [ $SIM -eq "1" ]; then printf "Sim $BYPASS, ";
          else 
            if [ $CN -eq "1" ]; then printf "CN, "; fi
            if [ $BYPASS -ne "0" ]; then printf "Bypass=%02X! " $BYPASS; fi
          fi
          if [ $FEMODE -eq "0" ]; then printf "FM Off! "; fi
        fi
	let "REG = $REG + 1";
      fi
    done
    printf "\n"
#  )
  let "CB = $CB + 1"
done
#echo ",,,,,,,,,,,,,,,,,,,,,,,,,,,,,,, $HOSTNAME$1$FEM ,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,"
}

case "${1:0:1}" in
  "b") SP_OPTION="-g";FEM="b";;
  "a")  SP_OPTION="";FEM="a";;
  *) usage; exit;;
esac

OPTIND=2        # skip first argument
while getopts "v:" opt; do
  #echo "opt=$opt"
  case $opt in
    v) VERB=$OPTARG;;
    \?) echo "Invalid option: -$OPTARG" >&2; exit 1;;
    :)  echo "Option -$OPTARG requires an argument." >&2; exit 1
esac
done

process_cmd
