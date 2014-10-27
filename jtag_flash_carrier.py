#!/usr/bin/python
#Flash carrier board with the latest CARB_U*.stp image
file = 'CARB_U1*.stp'
action = 'Device_info'
#action = 'Program'
#action = 'Verify'

import os
import glob
import sys
import subprocess  

if len(sys.argv) < 2:
  print("Script to flash the latest CARB_U*.stp image into the carrier board's FPGA")
  print('usage: '+sys.argv[0]+' [a/b][0:3] [U1/U2] [Program / Verify / Device_info / Read_idcode]')
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

fpgas = ['U1','U2']
if len(sys.argv) > 2: 
  if sys.argv[2][:2] not in fpgas:
    print('Second argument should be U1 or U2')
    exit()
  file = 'CARB_' + sys.argv[2] + '*.stp'

if len(sys.argv) > 3:
  action = sys.argv[3]

carrier_mask = 1
if len(sys.argv[1])>1:
  carrier_mask = 1 << int(sys.argv[1][1])

wiringpi2.pinMode(select_gpio,1)
wiringpi2.digitalWrite(select_gpio,0)

cmdline = 'Play_stapl.py ' + splayer_option + ' i1c ' + str(carrier_mask)

print('gpio -g write '+str(select_gpio)+' 0')
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
print('gpio -g write '+str(select_gpio)+' 1')

newest = max(glob.iglob(file), key=os.path.getctime)

cmdline = 'StaplPlayer ' + splayer_option + ' -a' + action + ' ' + newest
print('Executing: '+cmdline)
p = subprocess.Popen(cmdline, shell=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
for line in p.stdout.readlines():
  print line,
retval = p.wait()

wiringpi2.digitalWrite(select_gpio,0)
print('gpio -g write '+str(select_gpio)+' 0')

