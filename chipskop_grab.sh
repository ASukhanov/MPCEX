#!/bin/bash
ssh pinut -q 'cd work/MPCEX; 
ssh phast -q 'scp $(ls -t /tmp/*.dq4 | head -1) office:/tmp'
../Tdq/get_last_file.sh (END)

