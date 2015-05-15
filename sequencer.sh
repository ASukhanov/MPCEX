#!/bin/bash
usage()
{
cat << EOF
usage: $0 a/b/ab trig/ped/cal/svx options

Setup the sequencer for different types of run

OPTIONS:
  -v    verbose
  -h	help
EOF
}

FEM=""  
QUIET="1"
FEM=""
FEM1="a"
FEM2=""
SEQUENCE=""

execute_cmd()
{
  IRSCAN="Play_stapl.py $FEM i16 "
  CMD="$IRSCAN $DRSCAN"
  if [ $QUIET -eq "0" ]; then echo "Executing: $CMD"; fi
  eval $CMD > /dev/null
  echo "Sequencer on FEM.$FEM1 is set for $SEQUENCE"
}

if [ "$#" -lt "2" ]; then usage; exit 1; fi

case "$1" in
  "b")	FEM="-g"; FEM1="b" ;;
  "a")	;;
  "ab")	FEM2="-g" ;;
  *) usage ;;
esac

OPTIND=3        # skip first arguments
while getopts ":vh" opt; do
  case $opt in
    v) QUIET="0" ;;
    h) usage ;;
  esac
done

# Note, the sequencer Repeat command (code xxx1nnnn repeats the previous command nnnn times 
SEQUENCE=$2

case "$2" in
  cal) # for internal trigger with CalSR
    DRSCAN="1FF00000 00000020 00110002 002000E0 00300020 00410008 00500060 00600020 00710002 008000A0 00900020 00A10800 00B20020 00C00000 1FF00000"
#                          FM       R2       FM+PARst FM       R8       FM+Cal   FM       R2       FM+L1    FM       R800     FM+EOL
    ;;
  ped) # for internal trigger without CalSR
    DRSCAN="1FF00000 00000020 00110002 002000E0 00300020 00410008 00500020 00600020 00710003 008000A0 00900020 00A10100 00B20020 00C00000 1FF00000"
#                          FM       R2       FM+PARst FM       R8       FM       FM       R3       FM+L1    FM       R800     FM+EOL
    ;;
  trig_parst) # External trigger with periodic PARst
    DRSCAN="1FF00000 00000020 00110800 002000E0 00320020 00400000 1FF00000"
#                          FM     R800 FM+PARst   FM+EOL
    ;;
  trig) # External trigger without PArst :
    DRSCAN="1FF00000 00000020 00110800 00200020 00320020 00400000 1FF00000"
    ;;
  svx) # For downloading SVXs
    DRSCAN="1FF00000 00000020 0012000 00300000 1FF00000"
    ;;
  *)
    usage
    exit 1
esac

execute_cmd

if [ "$FEM2" != "" ]; then 
  FEM=$FEM2
  FEM1="b"
  execute_cmd
fi
