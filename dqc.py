#!/usr/bin/python
version = "v1 2016-04-06. "
def usage():
  print('Simple udp receiver. '+version+\
    'usage: '+sys.argv[0]+ ' options')
  print('Options:')
  print('  -v: verbose')
  print('  -w1: write to first file system')
  print('  -w2: write to second file system')

# settings
# two file systems 
#data_directory = "/tmp/","/tmp" # the same file system
data_directory = "/mnt/disk1/data/","/mnt/disk2/data/"
MaxFileSize = 0.1e9
HOST = ''   # Symbolic name meaning all available interfaces
#HOST = '255.255.255.255'
PORT = 1792 # FEM port
max_events=1000000000
PACKET_SIZE = 7000

import socket
#import select
import time
import sys
import struct
import binascii
import getopt
import datetime
 
OFS=0
packet = bytearray(OFS+PACKET_SIZE);
sender_prev=''
events=0
delta_time=10
writing_enabled = 0
dump_enabled = False
IDLE_LENGTH=44
run_started=0
sfil = None

prevev=0
missed_events_since_last_report = 0

def report():
  global prevev, missed_events_since_last_report, run_started, sfil
  txtout  = str(difftime)+'s, '
  txtout += hex(evnum)+' ev#'+str(events)+', evLen='+str(pktlen)
  txtout += ' accepted: '+str((events-prevev)/delta_time)+','
  txtout += ' produced: '+str((events-prevev+missed_events_since_last_report)/delta_time)+','
  #txtout += ' nErrLen='+str(nerrlen)+', nErrL1S='+str(nErrL1S)+', nCIDErr='
  if sfil:
    txtout += ' f'+str(writing_enabled)+':'+str(sfil.tell()/MaxFileSize*100)[:4]+'%'
  prevev = events
  missed_events_since_last_report = 0
  #txtout += ', bytes in: '+str(bytesin) + ', out: '+str(bytesout)+'kB '
  print(txtout)
  if sfil:
     if sfil.tell()/MaxFileSize > 0.99:
          fpos = sfil.tell()
          print ('Closed '+sfil.name+'['+str(fpos)+']')
          sfil.close()
          run_started = 0
try:
  opts,args = getopt.getopt(sys.argv[1:], 'hw:vn:', ["help", "write to disk", "verbose", "n="])
except getopt.GetoptError as err:
        # print help information and exit:
        print str(err) # will print something like "option -a not recognized"
        usage()
        sys.exit(2)
verbose = False
for o, a in opts:
        if o == "-v":
            verbose = True
        elif o in ("-h", "--help"):
            usage()
            sys.exit()
        elif o in ("-w", "--write"):
            writing_enabled = int(a)
            print('Writing to '+data_directory[writing_enabled-1]+' enabled')
        elif o in ("-n", "--number"):
            max_events = int(a)
            print("max_events = "+str(max_events))
        else:
            assert False, "unhandled option"

# Datagram (udp) socket
try :
    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    #print ('Socket created')
except socket.error, msg :
    print ('Failed to create socket. Error Code : ' + str(msg[0]) + ' Message ' + msg[1])
    sys.exit()
 
# Bind socket to local host and port
try:
    s.bind((HOST, PORT))
except socket.error , msg:
    print('Bind failed. Error Code : ' + str(msg[0]) + ' Message ' + msg[1])
    sys.exit()
    print('Socket bind complete')

#rc =  s.setsockopt(socket.SOL_SOCKET, socket.SO_RCVBUF, bufferSize)
#s.setblocking(0)

start = time.time()
olddifftime = 0
while 1:
    # receive packet, blocking mode
    pktlen, sender = s.recvfrom_into(packet, PACKET_SIZE)
    '''
    # receive packet non-blocking
    result = select.select([s],[],[])
    pktlen, sender = result[0][0].recvfrom_into(packet, PACKET_SIZE)
    '''
    if not packet: 
        break

    # event received
    if (sender != sender_prev):
      sender_prev = sender
      print('Packet['+str(pktlen)+'] from '+str(sender))

    if pktlen == IDLE_LENGTH:
      if run_started == 1:
        elapsed_sec = time.time() - start
        print('Run stopped, evLen= ' + str(pktlen))
        run_started = 0
        report()
        if sfil and not sfil.closed:
          fpos = sfil.tell()
          txtout = 'Closed '+sfil.name+'['+str(fpos)+'] after '+str(round(elapsed_sec,1))+'s'
          print(txtout)
          sfil.close()
      continue

    if  run_started == 0:
                expected_length = pktlen
                print('Run started, evLen= ' + str(pktlen))
                run_started = 1
                bytesin = 0.
                if writing_enabled>0:
                        filename = datetime.datetime.today().strftime("%y%m%d%H%M.dq4")
                        sfil = open(data_directory[writing_enabled-1]+filename,'wb')
                        if not sfil.closed:
                                txtout = 'Opened '+sfil.name
                                print(txtout)
                start = time.time()
                olddifftime = 0
                nErrL1S = 0
                nErrLPar = 0
                errcnt = 0
                nerrlen = 0
                nEmptyEvents = 0

    events +=1;
    evnum = packet[OFS]*256 + packet[OFS+1]
    #print('e:'+str(evnum))
    if verbose:
      print('l:'+str(pktlen)+' h:'+binascii.hexlify(packet[OFS:OFS+20])
      +' d:'+binascii.hexlify(packet[OFS+20:OFS+30])+' t:'+binascii.hexlify(packet[pktlen-8:pktlen]))
    if events == 1:
      prevnum = evnum
    if prevnum == evnum:
      missed_ev = 0
    else:
      missed_ev = evnum - prevnum - 1
    prevnum = evnum
    if missed_ev < 0:
        missed_ev += 65536 # correct for 16-bit overflow
    missed_events_since_last_report += missed_ev

    difftime = int((time.time() - start))
    #if difftime/delta_time != olddifftime/delta_time:
    if difftime >= olddifftime + delta_time:
      report()
      olddifftime = difftime

    if sfil and not sfil.closed:
            sfil.write(struct.pack('1i',pktlen)) # adds 5% cpu occupancy
            sfil.write(packet[:pktlen])
            #bytesout = round(sfil.tell()/1000.,1)

    if events >= max_events:
      print('Stopped after '+str(max_events)+' events')
      if sfil and not sfil.closed:
        sfil.close()
      break

s.close()
