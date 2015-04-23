#!/usr/bin/python
import sys, getopt
import serial

def usage():
  print ('Usage: '+sys.argv[0]+' options\n\n\
OPTIONS:\n\
-c mask	: turn on/off channels defined by hex mask\n\
-f	: force -c\n\
-h	: help\
-a	: read analog voltage\n\
-d	: read digital voltage\n\
-v	: verbose\n\
none	: print hardware version\n\n\
EXAMPLES:\n\
to switch on ch 7 & 4:'+sys.argv[0]+' -c 10010000 \n')

need_readback = False
forced=0
verbose=0
cmd=''

try:
  opts,args = getopt.getopt(sys.argv[1:],"c:fadhv")
except getopt.GetoptError:
  usage()
  exit(2)

if ('-f','') in opts:
  forced=1

for opt, arg in opts:
  #print ('opt:'+opt+', arg:'+arg)
  if opt == ("-a"):
    #cmd = '#20S10'
    print("readback of analog voltage is not implemented")
  elif opt == ("-d"):
    #cmd = '#20S20'
    print("readback of digital voltage is not implemented")
  elif opt == ("-f"):
    pass # already processed
  elif opt == ('-v'):
    verbose = 1   
  elif opt == ("-c"):
    channel_mask = arg
    cm = int('0b' + channel_mask,2)
    if(cm>255):
      usage()
      exit(2)
    cmd = '#20S00000'+hex(cm)[2:].zfill(2)
    if (cm == 0): print ('Switching OFF all channels')
    else:
      print ("Switching ON channels "),
      for ii in range(8) :
        if(cm&(1<<ii)): print (str(ii+1)+','),
      if forced :
        print("")
      else:
        print('. Are you sure? [y/n]: '),
        if raw_input().lower() != 'y': exit()
  else:
    usage()
    exit(2)
#exit()

#ser = serial.Serial('/dev/ttyUSB0', 38400, timeout=0, parity=serial.PARITY_EVEN, rtscts=1)
ser = serial.Serial('/dev/ttyUSB0', 38400, timeout=1)
if verbose:
  print('port opened: '+ser.name)
  print('baudrate='+str(ser.baudrate)+' parity='+str(ser.parity)+' rtscts='+str(ser.rtscts)
	+' timeout='+str(ser.timeout))
  print('wtite('+cmd+')')
ser.write('$20F\r')	#print version?
readback = ser.readline()
print ('MPCEX Power Distribution Controller version: '+readback)
ser.write(cmd+'\r')
if need_readback:
  readback = ser.readline()
  print ('read='+readback)

ser.close()
