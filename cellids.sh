#!/bin/bash
usage()
{
cat << EOF
usage: $0 [a/b] options

Print Cell IDs 

OPTIONS:
  -r N	repeat N times
  -v	verbose
  -d	print headers
  -b    print next 1k chunk of data
EOF
}
# defaults
CMD=""
VERB="0"
REPEAT="1"
ACTION="CELLIDS"
ERRCnt="0"
FEM="a"
ITEM_IN_LINE="0"

process_cmd()
{
  if [ $VERB -ge "2" ]; then echo "Executing: $CMD"; fi

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
          if [ $ACTION == "HEADER" ]; then
            printf "$REG ";
          else
          case $ii in
            "1") printf "$FEM:ev $REG: ";;
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
          ITEM_IN_LINE=$((ii %= 32))
          if [ $ITEM_IN_LINE -eq "0" ]; then printf "\n"; fi
        fi
    done
    if [ $ERR -ne "0" ]; then ((ERRCnt=$ERRCnt+1)); printf "ERR#$ERRCnt"; fi
    printf "\n"
  }
}

if [ "$#" -lt "1" ]; then usage; exit 1; fi
OPTIND=2        # skip first argument
while getopts "r:v:dhb" opt; do
  case $opt in
    v)	VERB=$OPTARG;;
    r)	REPEAT=$OPTARG;;
    d)	ACTION="HEADER";;
    b)  ACTION="DUMP_NEXT1K";;
    h)  usage; exit 0;;
    :)	echo "Option -$OPTARG requires an argument." >&2; exit 1;;
  esac
done

CMD="StaplPlayer -a$ACTION dump_cellids.stp"

FEM=${1:0:1}
case "$1" in
  "b")	CMD="$CMD -g";;
  "a")	;;
  *) 	usage; exit 2;;
esac

while [ "$REPEAT" -gt "0" ];
do
  ((REPEAT-=1))
  process_cmd
  #echo "ERRCnt=$ERRCnt"
done
#echo "final ERRCnt=$ERRCnt"
#if [ $ERRCnt -gt "0" ]; then echo "ERRORS $ERRCnt";
#else echo "OK"
#fi
