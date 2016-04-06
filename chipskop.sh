#!/bin/bash
# Control of the FEM on-board logic analyzer
usage()
{
cat << EOF
usage: $0 [a/b/] options

Chipskop control

OPTIONS:
  -aSource:    Arm chipskop, the Source could be L1/0, Seq/1, Err/2, Rd/3
  -o N:        Trigger offset, N=[0..f]
  -p Filename: Plot the waveform from file
  -s:          Status
  -x N:        N=[0..2]. Alternative selection of multiplexed data lines [7:0]
  -r:          Retrigger mode, useful to probe last trigger
  -v N:        Verbosity
EOF
}

#USAGE="usage: $0 [a/b] arm_l1/arm_seq/arm_gap/plot [trig_offset=0:F] "

TRIG_OFFSET=0
SP_OPTION=""
CSK_RETRIGGER=2
CSK_START=1
CSK_SELECT_CARB0_D=2
CSK_SELECT_GTM=4


CSK_IDLE=0
CSK_RUN=$((CSK_START+CSK_IDLE))
#echo $CSK_RUN

#if [ "$#" -ge "3" ]; then TRIG_OFFSET=$3; fi

CMD=""
ARM=0
TRIG_OFFSET=0
FILE=""
MUX=0

case "$1" in
  "b") SP_OPTION="-g";;
  "a") SP_OPTION="";;
  *) usage; exit
esac

OPTIND=2        # skip first argument
while getopts "a:o:p:sv:x:r" opt; do
  case $opt in
    a) ARM=$OPTARG;
       case $ARM in
         L1) ARM=0;;
         Seq) ARM=1;;
         Err) ARM=2;;
         Rd) ARM=3;;
         0);;
         1);;
         2);;
         3);;
         *) echo "Wrong Arm source"; usage;;
       esac;;
    o) TRIG_OFFSET=$OPTARG;;
    p) echo "executing: ./plot_chipskop.py $OPTARG"; ./plot_chipskop.py $OPTARG; exit;;
    s) ;;
    x) MUX=$OPTARG;;
    r) CSK_RUN=$((CSK_RUN+CSK_RETRIGGER));;
    v) VERB=$OPTARG;;
    \?) echo "Invalid option: -$OPTARG" >&2; usage; exit 1;;
    :)  echo "Option -$OPTARG requires an argument." >&2; usage; exit 1;;
  esac
done

CMD="Play_stapl.py $SP_OPTION i1e $MUX$ARM$CSK_RUN$TRIG_OFFSET $ARM$CSK_IDLE$TRIG_OFFSET" # |./splayer_dump.py"
echo "Executing: $CMD"
$CMD
# > /dev/null
