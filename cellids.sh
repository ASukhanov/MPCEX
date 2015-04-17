#!/bin/bash
usage()
{
cat << EOF
usage: $0 [a/b] options

Print Cell IDs 

OPTIONS:
  -r N	repeat N times
  -v	verbose
EOF
}
# defaults
CMD=""
VERB="0"
REPEAT="1"

process_cmd()
{
#echo "CMD= $CMD"
(eval $CMD;) | (
ii="0"
while read STR
do
      if [ $VERB -eq "3" ]; then echo $STR;
      else
        STR=${STR#*value = }    #
        if [ "${STR:0:3}" == "HEX" ]; then
          ((ii=$ii+1))
          REG=${STR:4:8}
          if [ $ii -eq "1" ]; then printf "ev $REG: ";
          else printf "$REG "; fi
        fi
      fi
done
printf "\n"
)
}
if [ "$#" -lt "1" ]; then usage; exit 1; fi
OPTIND=2        # skip first argument
while getopts ":r:v" opt; do
  case $opt in
    v)	VERB="1";;
    r)	REPEAT=$OPTARG;;
    :)	echo "Option -$OPTARG requires an argument." >&2; exit 1;;
  esac
done

CMD="StaplPlayer $FEM -acellids dump_cellids.stp"

case "$1" in
  "b")	CMD="$CMD -g";;
  "a")	;;
  *) 	usage; exit 2;;
esac

if [ $VERB -eq "1" ]; then eval $CMD; exit; fi

while [ "$REPEAT" -gt "0" ];
do
  ((REPEAT-=1))
  process_cmd
done
