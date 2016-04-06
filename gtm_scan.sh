#!/bin/bash
usage()
{
cat << EOF
usage: $0 a/bN options

Cell ID test with scanning all the possible timings of local GTM signals.

OPTIONS:
  -vV  Verbosity, default 1.
EOF
}
VERB=1
#CHECK_CELLID=0 #

OPTIND=2        # skip first argument
while getopts ":v:f:dhpr" opt; do
  case $opt in
    v) VERB=$OPTARG;;
#    c) CHECK_CELLID=1;;
    h) usage; exit 1;;
    \?) echo "Invalid option: -$OPTARG" >&2; exit 1;;
    :)  echo "Option -$OPTARG requires an argument." >&2; exit 1
esac
done

#select FEM
#FEM=${1:0:1}
FEM=$1

# stop previous run, re-running without it will cause immediate cell ID lockup
./gtm_local.sh $FEM -gstop; ./femoff.sh $FEM;

#start new run
./femon.sh $FEM -s1; ./view_status.sh $FEM -s1 -v5;

# The hard test
# 15-pulse trains (-t15) at 1.25KHz (-p5)
echo "**** The hard test. 15-pulse decreasing interval scan at 1.25 KHz ****"
for ii in {255..14}
do # if -i=195 then 4 L1s will be in the SVX4 stack
  CMD="./gtm_lkl.sh $FEM -d1 -t15 -p5 -i$ii -gen;"
  #echo "executing: $CMD"
  eval $CMD
  sleep 1
done

#delay scan with 4-pulse train at max speed = 5KHz
echo "**** Gap Delay scan with 4-pulse train at 5 KHz ****"
for ii in {0..255}
do #
  CMD="./gtm_lkl.sh $FEM -d$ii -t4 -p3 -i14 -gen;"
  #echo "executing: $CMD"
  eval $CMD
  sleep 1
done

# 4-pulse trains (-t4) at 5KHz (-p3)
echo "**** 4-pulse interval scan at 5KHz ****
for ii in {14..255}
do #
  CMD="./gtm_lkl.sh $FEM -d1 -t4 -p3 -i$ii -gen;"
  #echo "executing: $CMD"
  eval $CMD
  sleep 1
done

# 5-pulse trains (-t5) at 2.5KHz (-p4)
echo "**** 5-pulse interval scan at 2.5 KHz ****
for ii in {100..255}
do # start with i=100 to avoid more than 4 in the SVX4 stack
  CMD="./gtm_lkl.sh $FEM -d1 -t5 -p4 -i$ii -gen;"
  #echo "executing: $CMD"
  eval $CMD
  sleep 1
done

# continue running at highest rate
  CMD="./gtm_lkl.sh $FEM -d1 -t15 -p4 -i$14 -gen;"
  eval $CMD

