#!/usr/bin/python
# Set all carriers to Channel_Numbers mode.
# The ROCs will output the channel numbers instead of ADC values.

# Settings

#import os
#import glob
import sys
import subprocess

if len(sys.argv) < 2:
  print("Script to set all carriers to Channel_Numbers mode")
  print('usage: '+sys.argv[0]+' [a/b]')
  exit()

splayer_option = ''

if sys.argv[1][0] == 'b':
    splayer_option = '-g'
#    select_gpio = 7
elif sys.argv[1][0] != 'a':
  print('First letter should be a or b')
  exit()

carrier_set = [0,1,2,3]

for carrier in carrier_set:

  cmdline = 'Play_stapl.py ' + splayer_option + ' i1c ' + str(1<<carrier) + '|./splayer_dump.py' 
  print('Executing: '+cmdline)
  p = subprocess.Popen(cmdline, shell=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
  for line in p.stdout.readlines():
    print line,
  retval = p.wait()

  # The Following JTAG action is executed on the carrier board
  cmdline = 'Play_stapl.py ' + splayer_option + ' -c i30 ' + '140' + '|./splayer_dump.py'
  print('Executing: '+cmdline)
  p = subprocess.Popen(cmdline, shell=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
  for line in p.stdout.readlines():
    print line,
  retval = p.wait()
  
exit()
