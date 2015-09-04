#!/bin/bash
usage()
{
cat << EOF
usage: $0 t/b MASK

Switch on/off the low voltage channels

OPTIONS:
EOF
}
case "${1:0:1}" in
  "b")
    PREFIX="3"; USB="0";;
  "t")
    PREFIX="2"; USB="1";;
  *)
    usage; exit 1;
esac

MASK=$2

CMD="ssh -i ~/.ssh/id_rsa_nopass phnxmpcex@192.168.100.233 'echo -en \"#${PREFIX}0S00000${MASK}\x0d\" > /dev/ttyUSB$USB'"

echo "executing: $CMD"
eval $CMD
