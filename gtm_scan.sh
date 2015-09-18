#!/bin/bash
# scan all the possible timings with pulse trains

# stop previous run, re-running without it will cause immediate cell ID lockup
./gtm_local.sh a -gstop; ./femoff.sh;

#start new run
./femon.sh; ./view_status.sh a; 

# The hard test
# 15-pulse trains (-t15) at 1.25KHz (-p5)
echo "**** The hard test. 15-pulse decreasing interval scan at 1.25 KHz ****"
for ii in {255..14}
do # if -i=195 then 4 L1s will be in the SVX4 stack
  CMD="./gtm_local.sh a -d1 -t15 -p5 -i$ii -gen; ./cellids.sh a -v1; sleep 1;"
  #echo "executing: $CMD"
  eval $CMD
done

#delay scan with 4-pulse train at max speed = 5KHz
echo "**** Gap Delay scan with 4-pulse train at 5 KHz ****"
for ii in {0..255}
do #
  CMD="./gtm_local.sh a -d$ii -t4 -p3 -i14 -gen; ./cellids.sh a -v1; sleep 1;"
  #echo "executing: $CMD"
  eval $CMD
done

# 4-pulse trains (-t4) at 5KHz (-p3)
echo "**** 4-pulse interval scan at 5KHz ****
for ii in {14..255}
do #
  CMD="./gtm_local.sh a -d1 -t4 -p3 -i$ii -gen; ./cellids.sh a -v1; sleep 1;"
  #echo "executing: $CMD"
  eval $CMD
done

# 5-pulse trains (-t5) at 2.5KHz (-p4)
echo "**** 5-pulse interval scan at 2.5 KHz ****
for ii in {100..255}
do # start with i=100 to avoid more than 4 in the SVX4 stack
  CMD="./gtm_local.sh a -d1 -t5 -p4 -i$ii -gen; ./cellids.sh a -v1; sleep 1;"
  #echo "executing: $CMD"
  eval $CMD
done

# continue running at hichest rate
  CMD="./gtm_local.sh a -d1 -t15 -p4 -i$14 -gen; ./cellids.sh a -v1; sleep 1;"
  eval $CMD

