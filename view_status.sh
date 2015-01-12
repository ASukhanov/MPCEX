#!/bin/bash
# view FEM registers

CMD="Play_stapl.py i11 0 i12 0 i14 0 i17 0 i20 0 i21 0 i24 0"
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
