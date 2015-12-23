#!/bin/bash
usage()
{
cat << EOF
usage: $0 [a/b/ab] options

Print FEM registers

OPTIONS:
  -s N  skip every N-th event
  -v N  verbosity
EOF
}
# defaults
CSR20="00000000"
CSR21="00000000"
SKIP="0"	# do not skip events
VERB=7
STATUS=""

process_cmd()
{
#echo "CMD= $CMD"
(eval $CMD;) | (
ii="0"
while read STR
do
      if [ $VERB -eq "3" ]; then echo $STR;
      else
        STR=${STR#*value = }	#
        if [ "${STR:0:3}" == "HEX" ]; then
          let "ii=$ii+1"
          REG=${STR:4:8}
          if [ $ii -eq "2" ]; then CSR12=$((16#$REG)); fi
          if [ $ii -eq "3" ]; then CSR14=$((16#$REG)); fi
          if [ $ii -eq "4" ]; then CSR17=$((16#$REG)); fi
          if [ $ii -eq "5" ]; then CSR20=$((16#$REG)); fi
          if [ $((VERB & 4)) -ne "0" ]; then
          printf "$REG "; fi
        fi
      fi
done
if [ $((VERB & 4)) -ne "0" ]; then
  printf "\n"; fi

if [ $((VERB & 1)) -ne "0" ]; then
if [ $VERB -ne "0" ]; then
  printf "Ev=0x%04x: " $((CSR20 & 16#ffff))
  ((PMASK = ($CSR14&1) | (($CSR14>>10)&2) | (($CSR14>>17)&4) | (($CSR14>>23)&8) ))
  printf "PROuts:%1x:%1x%1x%1x%1x. " $PMASK $(((CSR14>>24)&7)) $(((CSR14>>16)&7)) $(((CSR14>>8)&7)) $(((CSR14)&7))
  if [ $((CSR12 & 16#00000080)) -eq 0 ] ;       then printf "ERR:Clock, "; fi
  if [ $((CSR17 & 16#f00fffff)) -ne $((16#20050800)) ];	then printf "ERR:Sequencer wrong, "; fi
  if [ $((CSR17 & 16#00f00000)) -ne 0 ] ; 	then printf "ATT:Blocked L1s, "; fi
  if [ $((CSR20 & 16#08000000)) -ne 0 ] ;	then printf "ERR:Halt, "; fi
  if [ $((CSR20 & 16#04000000)) -ne 0 ] ;       then printf "ERR:Overflow, "; fi
  if [ $((CSR20 & 16#02000000)) -ne 0 ] ;       then printf "ERR:Timeout, "; fi
  if [ $((CSR20 & 16#01000000)) -ne 0 ] ;       then printf "Readout, "; fi
  FIFO=$(((CSR20 >> 16)&15))
  if [ $FIFO -ne 3 ]; then printf "FIFO=%1x, " $FIFO; fi
  printf "\n"
fi
fi
)
}

OPTIND=2        # skip first argument
while getopts ":s:v:" opt; do
  case $opt in
    s)
      SKIP=$OPTARG
      ;;
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
#echo "skip=$SKIP, verb=$VERB"
let "SKIPEV = 1<<($SKIP&0x3)"

if [ $((VERB & 2)) -ne "0" ]; then
  if [ $SKIP -ne "0" ]; then echo "WARNING. EVENT SKIPPING IS ACTIVE! sending out only every $SKIPEV-th event"; fi
fi

#if [ "${HOSTNAME:6:1}" -eq "0" ]; then
#       #0000x0:  30011FC8 6307509C 45454545 20250800 50F30005 1E411E3C 19301105 00CA1848
#echo "$HOSTNAME:    i10  :   i12  :   i14  :   i17  :   i20  :   i21  :   i24  :   i25  "
#fi

CMD="Play_stapl.py i11 0 i12 0 i14 0 i17 0 i20 $SKIP i21 0 i24 0 i25 0"

case "$1" in
  "b")	CMD="$CMD -g"; process_cmd;;
  "a")	process_cmd;;
  *)
    #$CMD   |./splayer_dump.py
    #$CMD -g|./splayer_dump.py
    process_cmd
    CMD="$CMD -g"
    process_cmd
    ;;
#  *)	echo "ERROR: wrong FEM"; usage; ;;
esac
