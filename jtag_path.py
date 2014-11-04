#!/usr/bin/python

import sys
import subprocess
import wiringpi2
wiringpi2.wiringPiSetupSys()

if len(sys.argv) < 2:
  print('Script for JTAG access of a carrier board')
  print('Example to access carrier board 2 at FEM a: ./jtag_path a2')
  print('To recover the path to FEM on FEM a: ./jtag_path a')
  exit()

splayer_option = ''
select_gpio = 8

if sys.argv[1][0] == 'b':
    splayer_option = '-g'
    select_gpio = 7
elif sys.argv[1][0] != 'a':
  print('First letter should be a or b')
  exit()

wiringpi2.pinMode(select_gpio,1)
print('gpio -g write '+str(select_gpio)+' 0')
wiringpi2.digitalWrite(select_gpio,0)

carrier = 0
if len(sys.argv[1])==1:
  # Path is already t=set to FEM
  exit()

carrier = int(sys.argv[1][1])

cmdline = 'Play_stapl.py ' + splayer_option + ' i1c ' + str(1<<carrier) + '|./splayer_dump.py'
print('Executing: '+cmdline)
p = subprocess.Popen(cmdline, shell=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
for line in p.stdout.readlines():
  print line,
retval = p.wait()

wiringpi2.digitalWrite(select_gpio,1)
if wiringpi2.digitalRead(select_gpio) != 1 :
  print('ERROR. JTAG path through the FEM using GPIO pin ' + str(select_gpio) + ' was not established')
  print('Did you forget "gpio export '+ str(select_gpio) + ' out" after reboot?')
  exit(1)
print('gpio -g write '+str(select_gpio)+' 1')
print('JTAG access to '+sys.argv[1][:2]+' established')

exit()

