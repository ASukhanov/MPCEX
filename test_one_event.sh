#!/bin/bash
# Run for one event
Play_stapl.py  i10 50032fc0 i16 cff00000 i20 0 i21 0|./splayer_dump.py

echo "To dump:"
echo "StaplPlayer -aTrans dump_rbfifo-1k.stp |./splayer_dump.py"
echo "or"
echo "StaplPlayer -g -aTrans dump_rbfifo-1k.stp |./splayer_dump.py"

