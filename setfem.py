#!/usr/bin/python                                                                                                                      
# Setup FEM
csr=0x50032000        # default CSR
# for details see MPCEX FEM User Guide:
# https://docs.google.com/document/d/1Af5qRmYUNsfU-TkVpd8vJxEkcIqnKi_7xnJf8nlslEY/edit#heading=h.bjsg1osbwivb
#
version='v2'

import sys
import subprocess

def print_usage():
  print('Usage: '+sys.argv[0]+' a/b[Carriers] [trig/ped] [-gray] [cbtest] [femtest]')

if len(sys.argv) < 2:
  print('Setup the FEM. Version '+version)
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

for s in sys.argv[2:]:
        if s == 'trig':
          csr |= 0x00000000
        elif s == 'ped':
          csr |= 0x000000C0
	elif s == '-gray':
          csr |= 0x00001000 # disable Gray decoding
        elif s == "cbtest":
          csr |= 0x00100000 # force all chains into simulation mode by setting BClk=1
        elif s == "femtest":
          csr |= 0x00100004 # FEM simulation mode
        else:
          print('Unknown argument: '+s)
          print_usage()
          exit()

master = int(sys.argv[1][1])
carmask = 0
for b in sys.argv[1][1:]:
  carmask |= 1<<int(b) 

print('cm='+hex(carmask)+', m='+hex(master)+',='+hex((carmask | master)<<4))

csr |= (carmask<<8) | (master<<4)

cmdline = 'Play_stapl.py '+splayer_option+' i10 ' + hex(csr)[2:]
print('Executing: '+cmdline)
p = subprocess.Popen(cmdline, shell=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
for line in p.stdout.readlines():
  print line,
retval = p.wait()

exit()

