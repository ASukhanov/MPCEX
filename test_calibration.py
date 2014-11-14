#!/usr/bin/python
# Calibrarion run, the same as pedestal but FM+CalSr is inserted into the sequence

import os
import glob
import sys
import subprocess

if len(sys.argv) < 2:
  print("Calibration run on carrier boards FEM")
  print('Usage: '+sys.argv[0]+' a/b[Carriers]')
  print('Example to run calibartion on FEM a, carriers 0,2,3, master carrier 2:')
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

# Load sequencer with the pedestal sequence:
cmdline = 'Play_stapl.py i16 '
cmdline += '00000020 00110002 00200020 003000E0 00400020 00510008 00600060 00700020 '
#           FEMode   D2       FEMode   FM+PARST FEMode   D8       FM+CALSR FEMode
cmdline += '00810003 009000A0 00A00030 00B00020 00C10038 00D00020 00E10100 00F00020 '
#           D3       FM+L1    BEMode   FEMode   D38      FEMode   D100     FEMode
#cmdline += '01012000 01100020 01220000 01300000 01400000 |./splayer_dump.py'
cmdline += '01010800 01100020 01220000 01300000 01400000 |./splayer_dump.py' # Hi rate
#           D2000    D20      EOL 
print('Executing: '+cmdline)
p = subprocess.Popen(cmdline, shell=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
for line in p.stdout.readlines():
  print line,
retval = p.wait()

cmdline = 'Play_stapl.py i16 4ff00000 i20 0 i21 0 i10 50233' 
cmdline += hex(carmask)[2:] + hex(12+master)[2:] +'0 '
cmdline += 'i20 0 i21 0|./splayer_dump.py'
print('Executing: '+cmdline)
p = subprocess.Popen(cmdline, shell=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
for line in p.stdout.readlines():
  print line,
retval = p.wait()

#cmdline = 'Play_stapl.py i16 4ff00000 i20 0 i21 0|./splayer_dump.py' #one shot
cmdline = 'Play_stapl.py i16 2ff00000 i20 0 i21 0|./splayer_dump.py'
print('Executing: '+cmdline)
p = subprocess.Popen(cmdline, shell=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
for line in p.stdout.readlines():
  print line,
retval = p.wait()

print('To dump: StaplPlayer -aTrans dump_rbfifo-1k.stp | ./splayer_dump.py')
exit()
