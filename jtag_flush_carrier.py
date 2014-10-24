#!/usr/bin/python
#Flush carrier board with the latest CARB_U1
prefix = 'CARB_U1*.stp'
action = 'Device_info'

import os
import glob
import sys
import subprocess  

if len(sys.argv) < 2:
  print('No arguments')
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

carrier_mask = 1
if len(sys.argv[1])>1:
  carrier_mask = 1 << int(sys.argv[1][1])

wiringpi2.pinMode(select_gpio,1)
wiringpi2.digitalWrite(select_gpio,0)

cmdline = 'Play_stapl.py ' + splayer_option + ' i1c ' + str(carrier_mask)

print('gpio -g '+str(select_gpio)+' 0')
print('Executing: '+cmdline)
p = subprocess.Popen(cmdline, shell=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
for line in p.stdout.readlines():
  print line,
retval = p.wait()

wiringpi2.digitalWrite(select_gpio,1)
if wiringpi2.digitalRead(select_gpio) != 1 :
  print('ERROR JTAG path through FEM using GPIO pin ' + str(select_gpio) + ' was not established')
  print('Did you forget "gpio export '+ str(select_gpio) + ' out" after reboot?') 
  exit(1) 
print('gpio -g '+str(select_gpio)+' 1')

newest = max(glob.iglob(prefix), key=os.path.getctime)

cmdline = 'Play_stapl.py ' + splayer_option + ' -a' + action + ' ' + newest
print('Executing: '+cmdline)
p = subprocess.Popen(cmdline, shell=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
for line in p.stdout.readlines():
  print line,
retval = p.wait()

wiringpi2.digitalWrite(select_gpio,0)
print('gpio -g '+str(select_gpio)+' 0')

