#!/bin/bash
# view FEM registers

if [ "${HOSTNAME:6:6}" -eq "0" ]; then
       #0000x0:  30011FC8 6307509C 45454545 20250800 50F30005 1E411E3C 19301105 00CA1848
echo "$HOSTNAME:    i10  :   i12  :   i14  :   i17  :   i20  :   i21  :   i24  :   i25  "
fi

CMD="Play_stapl.py i11 0 i12 0 i14 0 i17 0 i20 0 i21 0 i24 0 i25 0"
case "$1" in
  "b")
    $CMD -g |./splayer_dump.py
    ;;
  "a")
    $CMD |./splayer_dump.py
    ;;
  *)
    $CMD   |./splayer_dump.py
    $CMD -g|./splayer_dump.py
    ;;
esac
