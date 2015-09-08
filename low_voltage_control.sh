#!/bin/bash
usage()
{
cat << EOF
usage: $0 MASK

Switch on/off the low voltage channels

OPTIONS:
  -t   top carrier board (ADDR=3)
  -b   bottom carrier board (ADDR=2)
  -uN  usb port
  -mNN hex mask of enabled channels
EOF
}
#defaults
ADDR="3" # address of bottom carrier
USB="0"
MASK="00" # off all the channels

while getopts "tbhu:m:" opt; do
  case $opt in
    t) ADDR="2";;
    b) ADDR="3";;
    h) usage; exit 1;;
    u) USB=$OPTARG;;
    m) MASK=$OPTARG;;
    \?) echo "Invalid option: -$OPTARG" >&2; exit 1;;
    :)  echo "Option -$OPTARG requires an argument." >&2; exit 1
esac
done

CMD="echo -en \"#${ADDR}0S00000${MASK}\x0d\" > /dev/ttyUSB$USB"

# for remote access, uncomment the following line:
#CMD="ssh -i ~/.ssh/id_rsa_nopass phnxmpcex@192.168.100.233 '$CMD'"

echo "executing: $CMD"
eval $CMD
