#!/usr/bin/python
# Pedestal run

import os
import glob
import sys
import subprocess

if len(sys.argv) < 2:
  print("One event and stop run")
  print('Usage: '+sys.argv[0]+' a/b[Carriers]')
  print('Examle to read pedestals from FEM a, carriers 0,2,3, master carrier 2:')
  print(sys.argv[0]+' a203')
  exit()

#import wiringpi2
#wiringpi2.wiringPiSetupSys()

splayer_option = ''
select_gpio = 8

if sys.argv[1][0] == 'b':
    splayer_option = '-g'
    select_gpio = 7
elif sys.argv[1][0] != 'a':
  print('First letter should be a or b')
  exit()

if len(sys.argv[1])<2:
  print('Master is not specified')
  exit()

master = 0
carmask = 0xf
#if len(sys.argv)>2:
master = int(sys.argv[1][1])
carmask = 0
for b in sys.argv[1][1:]:
  carmask |= 1<<int(b) 
#wiringpi2.pinMode(select_gpio,1)


cmdline = 'Play_stapl.py i10 50233'
cmdi10 = hex(carmask)[2:] + hex(12+master)[2:] +'0 '
cmdline += cmdi10 
cmdline += 'i16 4ff00000 i20 0 i21 0 i10 50033'
cmdline += cmdi10
cmdline += '|./splayer_dump.py'
print('Executing: '+cmdline)
p = subprocess.Popen(cmdline, shell=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
for line in p.stdout.readlines():
  print line,
retval = p.wait()

print('To dump: StaplPlayer -aTrans dump_rbfifo-1k.stp | ./splayer_dump.py')
exit()
