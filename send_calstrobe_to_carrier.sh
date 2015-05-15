#!/bin/bash
# Send Calstrobe to carrier boards to copy the configuration into a SEU-safe shadow register
USAGE="usage: $0 a/b/ab, IMPORTANT: configuration should be enabled using ./carrier_config.sh [a/b/ab] -d !"

CMD="i16 1ff00000 40 00120000 00200000 1ff00000 Cff00000"
#if [ "$#" -lt "1" ]; then echo $USAGE; exit; fi

SP_OPTION=""
SP_OPTION2=""
FEM="a"

execute_cmd(){
#echo "Executing Play_stapl.py $SP_OPTION $CMD"
eval Play_stapl.py $SP_OPTION $CMD > /dev/null
echo "Calstrobe is sent to FEM.$FEM"
# recover sequencer
./sequencer.sh $FEM trig
}

case "$1" in
  "b")	SP_OPTION="-g"; FEM="b";;
  "a");;
  "ab")	SP_OPTION2="-g";;
  *)	echo $USAGE; exit 1;;
esac

execute_cmd
if [ "$SP_OPTION2" != "" ]; then
  SP_OPTION=$SP_OPTION2
  FEM="b"
  execute_cmd
fi
#echo "WARNING! Sequencer have been modified, to set it for normal running: ./sequencer.sh $1 trig"
