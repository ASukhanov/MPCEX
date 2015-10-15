#!/bin/bash
usage()
{
cat << EOF
usage: $0 [a/b]

Disable FEMs for data taking
EOF
}
LOG=/phenixhome/phnxrc/MPCEXFinal/StaplPlayer_log.txt

if [ "$#" -gt "0" ]; then FEM=$1; else FEM="ab"; fi
#echo "${#1}"
#case "${1:0:1}" in
#  "a"|"b")
#    FEM=$1;OPTIND=2;;
#  
#esac

CMD="Play_stapl.py i16 1ff00000"

# FEMa
if [[ $FEM == *"a"* ]]; then
  echo "$HOSTNAME: Executing $CMD";
  $CMD > /dev/null;
fi

# FEMb
if [[ $FEM == *"b"* ]]; then
  echo "$HOSTNAME: Executing $CMD -g";
  $CMD -g > /dev/null;
fi
