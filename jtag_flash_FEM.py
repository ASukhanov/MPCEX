#!/usr/bin/python
# Flash the FEM firmware against the latest FEM*.stp
action = 'Device_info' # Deafult action

import os
import glob
import sys

if len(sys.argv) < 2:
  print("Flash the latest FEM*.stp image into FEM FPGA")
  print('usage: '+sys.argv[0]+' [a/b] [Program / Verify / Device_info / Read_idcode]')
  exit()

splayer_option = ''
if sys.argv[1] == 'b':
  splayer_option = '-g'
elif sys.argv[1] != 'a':
  print('First argument should be a or b')
  exit()

if len(sys.argv) > 2:
  action = sys.argv[2]

newest = max(glob.iglob('FEM*.stp'), key=os.path.getctime)

# execute the Verify action in the stapl file
import subprocess
cmdline = 'StaplPlayer ' + splayer_option + ' -a' + action + ' ' + newest
print('Executing:'+cmdline)
p = subprocess.Popen(cmdline, shell=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
for line in p.stdout.readlines():
  print line,
retval = p.wait()

