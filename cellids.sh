#!/bin/bash
usage()
{
cat << EOF
usage: $0 [a/b] options

Print Cell IDs 

OPTIONS:
  -r N	repeat N times
  -v	verbose
  -h	print headers
EOF
}
# defaults
CMD=""
VERB="0"
REPEAT="1"
ACTION="CELLIDS"
ERRCnt="0"

process_cmd()
{
  #echo "CMD= $CMD"

  # need lastpipe bash option, othervise the following subshell will not change the variables
  shopt -s lastpipe
  eval $CMD |
  {
    ii="0"
    ERR="0"
    while read STR
    do
      if [ $VERB -eq "3" ]; then echo $STR; fi;
        STR=${STR#*value = }    #
        if [ "${STR:0:3}" == "HEX" ]; then
          ((ii=$ii+1))
          REG=${STR:4:8}
          #printf "$ii,$REG\n"
          case $ii in
            "1") printf "ev $REG: ";;
            "2") PATTERN=$REG; if [ $VERB -gt "0" ]; then printf "$REG "; fi;;
            *) if [ $VERB -gt "0" ]; then printf "$REG"; fi;
               if [ $REG != $PATTERN ]; then
                 ERR="1"
                 if [ $VERB -gt "0" ]; then printf "_"; fi;
                 #if [ $VERB -gt "0" ]; then printf "ERR#$ERRCnt: $REG!=$PATTERN\n";fi;
               else if [ $VERB -gt "0" ]; then printf " "; fi;
               fi
               ;;
          esac
        fi
    done
    if [ $ERR -ne "0" ]; then ((ERRCnt=$ERRCnt+1)); printf "ERR#$ERRCnt"; fi
    printf "\n"
  }
}

if [ "$#" -lt "1" ]; then usage; exit 1; fi
OPTIND=2        # skip first argument
while getopts "r:v:h" opt; do
  case $opt in
    v)	VERB=$OPTARG;;
    r)	REPEAT=$OPTARG;;
    h)	ACTION="HEADER";;
    :)	echo "Option -$OPTARG requires an argument." >&2; exit 1;;
  esac
done

CMD="StaplPlayer $FEM -a$ACTION dump_cellids.stp"

case "$1" in
  "b")	CMD="$CMD -g";;
  "a")	;;
  *) 	usage; exit 2;;
esac

#if [ $VERB -eq "1" ]; then eval $CMD; exit; fi

while [ "$REPEAT" -gt "0" ];
do
  ((REPEAT-=1))
  process_cmd
  #echo "ERRCnt=$ERRCnt"
done
#echo "final ERRCnt=$ERRCnt"
if [ $ERRCnt -gt "0" ]; then echo "ERRORS $ERRCnt";
else echo "OK"
fi
