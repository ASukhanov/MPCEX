#!/bin/bash
VERB="2"
usage()
{
cat << EOF
usage: $0 [a/b][i] options

Download or read back SVX chains

OPTIONS:
  -t    test read back, CalStrobe not sent
  -1    download one module (2 SVX)
  -v N  verbosity, 0:3, default:$VERB
  -f    file to download

EXAMPLES:
download all carriers of Fem.a:  $0 a
download one module on second chain of Fem.b : $0 b1 1
EOF
}
# version #150420	Calstrobe removed, it should be external
# version v2 2016-04-28 Logging

NOPLAY=0

# CSR10: Local control (10000), All chains enabled (f00), triggers disabled (c0) , BClk (8)
CSR10_bits_19_00=14fc0
LOG="svx_download.log"
FILE_ALL="svxall_gain_high_drive_low.stp"
FILE_ONE="svx1.stp"
FILE=$FILE_ALL
NCHIPS="12"
READBACK="0"
SP_OPTION=""
RAWPRINT="0"

# Download all chains at once
#USAGE="usage: $0 [a/b][i] [1]"
#EXAMPLE="example: download all carriers of Fem.a:  $0 a;\n
#download one module on second chain of Fem.b : $0 b1 1;"

OPTIND=2	# skip first argument
while getopts ":v:t1f:" opt; do
  #echo "opt=$opt"
  case $opt in
    t)
      READBACK="1"
      ;;
    1)
      FILE=$FILE_ONE
      NCHIPS="2"
      ;;
    v)
      VERB=$OPTARG
      ;;
    f)
      FILE=$OPTARG
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

echo "======== $HOSTNAME.$1 ========" >> $LOG
date >> $LOG

FEM=${1:0:1}
case "$FEM" in
  "b")
    SP_OPTION="-g"
    ;;
  "a")
     SP_OPTION=""
    ;;
  *)
    echo "Wrong carrier board"
    usage
    exit 1
esac
if [ $VERB -ge "3" ]; then 
echo "Make sure that the configuration is opened using ./carrier_config.sh $FEM -d";
fi
if [ "${#1}" -eq "2" ]; then #echo "enabling only one chain ${1:0:2} for downloading";
  #noneed#CMD="Play_stapl.py $SP_OPTION i1c ${1:1:1}";	# setup JTAG path to the chain
  #noneed#if [ $VERB -ge "2" ]; then echo "Executing $CMD"; fi
  #noneed#eval $CMD >> /dev/null
  let "CHAIN = ${1:1:1}&0x3"
  let "VAL = 16#$CSR10_bits_19_00"
  let "VAL = $VAL&0xfffff0cf"	# clear bits 11:8 and 5:4
  let "VAL = $VAL|((1<<$CHAIN)<<8)"	# set bits 11:8
  #printf "val[11:8]=%08x\n" $VAL
  let "VAL = $VAL|(($CHAIN&0x3)<<4)"
  #printf "val[5:4]=%08x\n" $VAL
  CSR10_bits_19_00=`printf "%05x\n" $VAL`
  #echo "bits=$CSR10_bits_19_00"
fi

#./svx_conf.sh $FEM enable

# Reset carriers
CMD="Play_stapl.py $SP_OPTION i10 000$CSR10_bits_19_00"
if [ $VERB -ge "2" ]; then echo "Executing: $CMD"; fi
#echo "Executing: $CMD" >> $LOG
eval $CMD > /dev/null

# Download
if [ $NOPLAY != "1" ]; then
CMD="StaplPlayer $SP_OPTION -aTrans $FILE"
if [ $VERB -ge "2" ]; then echo "Executing: $CMD"; fi
(eval $CMD | tee -a $LOG) | (
ii=$NCHIPS
while read STR
do
  let "ii = $ii-1"
  #echo "STR: $STR"
  if [ $VERB -ge "3" ]; then echo "$STR";
  else if [ $VERB -ge "1" ]; then
    STR=${STR#*value = }
    if [ "${STR:0:3}" == "HEX" ]; then printf "svx[%02i]: %s\n" $ii ${STR:4:48}; fi
    fi
  fi
done
)
fi

# Reset carriers
CMD="Play_stapl.py $SP_OPTION i10 501$CSR10_bits_19_00 000$CSR10_bits_19_00"
if [ $VERB -ge "2" ]; then echo "Executing: $CMD"; fi
#echo "Executing: $CMD" >> $LOG
eval $CMD > /dev/null
#./svx_conf.sh $FEM disable
if [ $VERB -ge "3" ]; then
echo "WARNING. Do not forget to close configuration for normal data taking: ./carrier_config.sh $FEM";
echo "WARNING. Sequencer is modified. To recover: ./sequencer.sh $FEM trig";
fi
#echo "_______________________________ $HOSTNAME _________________________________" >> $LOG
