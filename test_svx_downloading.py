#!/usr/bin/python
# Download configuration into all carrier boards connected to FEM
# 2014-12-28	Version 2. i10[7:6] are set, this is internal trigger selection.

# Settings
#svxfile = 'svxall_gain_high_drive_max.stp'
svxfile = 'svxall_gain_high_drive_low.stp'
#svxfile = 'svxall_gain_high_drive_low_noFCLC.stp'

import os
import glob
import sys
import subprocess

if len(sys.argv) < 2:
  print("Script to download SVX4 chains of the FEM")
  print('usage: '+sys.argv[0]+' [a/b][0:3] [bypassing_mask]')
  print('example test carrier[2] on FEM a with bypassed ROC[0] and ROC[5]: '+sys.argv[0]+' b2 05')
  print('test with all ROCs bypassed at FEM a: '+sys.argv[0]+' a 012345')
  exit()

import wiringpi2
wiringpi2.wiringPiSetupSys()

splayer_option = ''
select_gpio = 8

if sys.argv[1][0] == 'b':
    splayer_option = '-g'
    select_gpio = 7
elif sys.argv[1][0] != 'a':
  print('First letter should be a or b')
  exit()
wiringpi2.pinMode(select_gpio,1)

carrier_set = [0,1,2,3]
if len(sys.argv[1])>1:
  carrier_set = [int(sys.argv[1][1])]

switch_mask = 0
if len(sys.argv)>2:
  for b in sys.argv[2]:
     switch_mask |= 1<<int(b) 
switches = hex(0x100+switch_mask)[2:]

# Reset the JTAG path to access FEM
#log#print('gpio -g write '+str(select_gpio)+' 0')
wiringpi2.digitalWrite(select_gpio,0)

for carrier in carrier_set:

  cmdline = 'Play_stapl.py ' + splayer_option + ' i1c ' + str(1<<carrier) + ' > /dev/null' 
  #log#print('Executing: '+cmdline)
  p = subprocess.Popen(cmdline, shell=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
  for line in p.stdout.readlines():
    print line,
  retval = p.wait()

  # If -c option in Play_stapl is specified, then the JTAG action will be  executed on the carrier board
  cmdline = 'Play_stapl.py ' + splayer_option + ' -c i30 ' + switches + ' > /dev/null'
  #log#print('Executing: '+cmdline)
  p = subprocess.Popen(cmdline, shell=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
  for line in p.stdout.readlines():
    print line,
  retval = p.wait()
  
  #^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  # Set in IR10: GTMLkl, CarBEn, MasterSel
  # Option: Only one carrier board receives SDO 
  cmdline = 'Play_stapl.py ' + splayer_option + ' i10 10' + str(1<<carrier) + hex(carrier+12)[2:] + '0' + ' > /dev/null' 
  # Option: All carriers receives SDO signals, good for carriers which needs the U2-U1 tunnels
  #cmdline = 'Play_stapl.py ' + splayer_option + ' i10 10' + 'f' + hex(carrier+12)[2:] + '0'
  #---------------------------------------
  #log#print('Executing: '+cmdline)
  p = subprocess.Popen(cmdline, shell=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
  for line in p.stdout.readlines():
    print line,
  retval = p.wait()

  cmdline = 'StaplPlayer ' + splayer_option + ' -aTrans ' + svxfile 
  #log#print('Executing: '+cmdline)
  p = subprocess.Popen(cmdline, shell=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
  for line in p.stdout.readlines():
    print line,
  retval = p.wait()

exit()
