#!/usr/bin/python                                                                                                                      
# Setup FEM
csr31_12='50032'        # default bits 31:12
# for details see MPCEX FEM User Guide:
# https://docs.google.com/document/d/1Af5qRmYUNsfU-TkVpd8vJxEkcIqnKi_7xnJf8nlslEY/edit#heading=h.bjsg1osbwivb

import sys
import subprocess

def print_usage():
  print('Usage: '+sys.argv[0]+' a/b[Carriers] trig/ped')

if len(sys.argv) < 2:
  print("Setup the FEM")
  print_usage()
  print('Example for FEM a: carriers 0,2,3, master carrier 2, external trigger:')
  print(sys.argv[0]+' a203 trig```')
  exit()


splayer_option = ''

if sys.argv[1][0] == 'b':
    splayer_option = '-g'
elif sys.argv[1][0] != 'a':
  print('First letter should be a or b')
  exit()

if len(sys.argv[1])<2:
  print('Master is not specified')
  exit()

trig_source=0
if len(sys.argv) > 2:
        if sys.argv[2] == 'trig':
          trig_source = 0x0
        elif sys.argv[2] == 'ped':
          trig_source = 0xC
        else:
          print_usage()
          exit()

master = int(sys.argv[1][1])
carmask = 0
for b in sys.argv[1][1:]:
  carmask |= 1<<int(b) 

cmdline = 'Play_stapl.py '+splayer_option+' i10 ' + csr31_12 
cmdline += hex(carmask)[2:] + hex(trig_source+master)[2:] +'0 '
print('Executing: '+cmdline)
p = subprocess.Popen(cmdline, shell=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
for line in p.stdout.readlines():
  print line,
retval = p.wait()

exit()

