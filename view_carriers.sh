#!/bin/bash
# Print CSR of the cartrier boards
# version vD1

SP_OPTION=""

USAGE="usage: $0 [a/b]"
LOG=/phenixhome/phnxrc/MPCEXFinal/StaplPlayer_log.txt

if [ "$#" -lt "0" ]; then echo $USAGE; exit; fi
case "$1" in
  "b"|"-g")
    SP_OPTION="-g"
    ;;
  "a")
    SP_OPTION=""
    ;;
  *)
    echo $USAGE
    exit
    ;;
esac

#CMD="Play_stapl.py $SP_OPTION i1c $CBMASK > /dev/null; Play_stapl.py -c $SP_OPTION i32 0 i33 0;"

echo "''''''''''''''''''''''''''''''' $HOSTNAME.$1 '''''''''''''''''''''''''''''''''"
CB=0
for i in 1 2 4 8; do
  Play_stapl.py $SP_OPTION i1c $i > /dev/null;
  REG=0
  (Play_stapl.py -c $SP_OPTION i32 0 i33 0;) | (
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
          printf "FM=$FEMODE PROut=$PROUT CMD=%02x PR2=%03x PAR=%02x L0=%02x " $LAST_CMD $PR2 $PAR $L0
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
  )
  let "CB = $CB + 1"
done
echo ",,,,,,,,,,,,,,,,,,,,,,,,,,,,,,, $HOSTNAME.$1 ,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,"
