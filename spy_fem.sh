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
#version 2 2015-10-24
#version 2 2016-01-05  echo "   b10/b32/b10/b32/CId/CId/PL1/H  /EBC/ PT/ V / BC/ FN/

# defaults
CMD=""
VERB="1"
REPEAT="1"
ACTION="DUMP_CELLIDS"
ERRCnt="0"
FEM="a"
ITEM_IN_LINE="0"

CELLID=""

process_cmd()
{
  if [ $VERB -ge "3" ]; then echo "Executing: $CMD"; fi

  # need lastpipe bash option, othervise the following subshell will not change the variables
  #shopt -s lastpipe
  eval $CMD |
  {
    ii="0"
    ERR="0"

    # first line: comment
    while
    read STR
    do
    if [ $VERB -ge "3" ]; then echo "$FEM:$STR";fi;
    case "${STR:15:6}" in
      "Header")
        STR=${STR#*HEX}
        echo "$FEM:$STR"
        #        02020202030303030101010103CA2FFF0000000EF82A00194F00F0C200019046"
        echo "   b10/b32/b10/b32/CId/CId/PL1/H  /EBC/ PT/ V / BC/ FN/   /S_D/ EV/"
        break
        ;;
      "Payloa")
        STR=${STR#*HEX}
        echo "$FEM:$STR"
        ;;
      "CellID")
        #second line: 18 of CellId's
        read STR2
        #third line: 6 CellIds and event number
        read STR3
        STR=$STR2$STR3
        if [ $VERB -ge "2" ]; then echo "$FEM:$STR"; fi;
        CELLID=${STR:0:4}
        for ii in {1..23}
        do
          if [ "${STR:$ii*4:4}" != $CELLID ]; then
            ERR="1"
            if [ $VERB -ge "3" ]; then echo "$FEM:ERROR. Id[$ii] ${STR:$ii*4:4} != $CELLID"; fi
          fi
        done
        if [ $ERR -ne "0" ]; then
          ((ERRCnt=$ERRCnt+1));
          if [ $VERB -gt "0" ]; then echo "$FEM:ev ${STR:24*4:4}: ERR#$ERRCnt"; fi
        fi
        break
        ;;
      *) echo "$FEM:ERROR. Unexpected STAPL output: $STR"; exit;; 
    esac
    done
  }
}

if [ "$#" -lt "1" ]; then usage; exit 1; fi
OPTIND=2        # skip first argument
while getopts "r:v:dhb" opt; do
  case $opt in
    v)	VERB=$OPTARG;;
    r)	REPEAT=$OPTARG;;
    d)	ACTION="DUMP_HEADER";;
    b)  ACTION="DUMP_NEXT1K";;
    h)  usage; exit 0;;
    :)	echo "Option -$OPTARG requires an argument." >&2; exit 1;;
  esac
done

CMD="StaplPlayer -a$ACTION dumpfem.stp"

FEM=${1:0:1}
case "$1" in
  "b")	CMD="$CMD -g";;
  "a")	;;
  *) 	usage; exit 2;;
esac

shopt -s lastpipe
while [ "$REPEAT" -gt "0" ];
do
  ((REPEAT-=1))
  process_cmd
  #echo "ERRCnt=$ERRCnt"
done
#echo "final ERRCnt=$ERRCnt"
if [ $ERRCnt -gt "0" ]; then echo "ERRORS $ERRCnt";
  else if [ $ACTION == "DUMP_CELLIDS" ];  then echo "OK"; fi
fi
