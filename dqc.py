#!/usr/bin/python
def usage():
  print('Simple udp receiver. '+version+\
    'usage: '+sys.argv[0]+ ' options')
  print('Options:')
  print('  -v: verbose')
  print('  -w1: write to first file system')
  print('  -w2: write to second file system')
  print('  -nN:	take N events')
  print('  -r:  receive raw ethernet packets')
  print('  -t:  put 16-bit time stamp in the event header[8]')

#version = "v1 2016-04-06. "
#version = "v2 2016-04-28" # event counter cleared each run
#version = "v3 2016-05-24" # raw ethernet handling
version = "v4 2016-06-06" # -t option 

# settings
# two file systems 
#data_directory = "/tmp/","/tmp" # the same file system
data_directory = "/mnt/disk1/data/","/mnt/disk2/data/"
MaxFileSize = 4.0e9
HOST = ''   # Symbolic name meaning all available interfaces
#HOST = '255.255.255.255'
#HOST = '192.168.0.72' # optional, hard-coded IP of the FEM

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
run_started = False
sfil = None
time_stamping = False

prevev=0
missed_events_since_last_report = 0

raw_ethernet=False
my_sender = '192.168.0.71'

def report():
  global prevev, missed_events_since_last_report, run_started, sfil
  txtout  = str(difftime)+'s, '
  txtout += hex(evnum)+' ev#'+str(events)+', evLen='+str(pktlen)
  txtout += ' lost: '+str(missed_events_since_last_report)
  txtout += ' rcvd/s: '+str(float(events-prevev)/float(delta_time))+','
  txtout += ' prod/s: '+str(float(events-prevev+missed_events_since_last_report)/float(delta_time))+','
  if sfil:
    txtout += ' f'+str(writing_enabled)+':'+str(sfil.tell()/MaxFileSize*100)[:4]+'%'
  prevev = events
  missed_events_since_last_report = 0
  print(txtout)
  if sfil:
     if sfil.tell()/MaxFileSize > 0.99:
          fpos = sfil.tell()
          print ('Closed '+sfil.name+'['+str(fpos)+']')
          sfil.close()
          run_started = False
try:
  opts,args = getopt.getopt(sys.argv[1:], 'hw:vn:rt', ["help", "write to disk", "verbose", "n="])
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
            if a in ('1','2'):
              writing_enabled = int(a)
              print('Writing to '+data_directory[writing_enabled-1]+' enabled')
            else:
              assert False, "only -w1 and w2 options allowed"
        elif o in ("-n", "--number"):
            max_events = int(a)
            print("max_events = "+str(max_events))
        elif o in ("-r", "--raw"):
            raw_ethernet = True
            print("raw mode is for debugging, requires superuser privilege, the event format in file will be non-standard.")
        elif o in ("-t", "--tstamp"):
            time_stamping = True
            print("ATTENTION! Time stamping is enabled!")
        else:
            assert False, "unhandled option"

# Datagram (udp) socket
try :
    if not raw_ethernet:
      s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    else:
      s = socket.socket(socket.AF_INET, socket.SOCK_RAW, socket.IPPROTO_UDP)
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
current_time = start
olddifftime = 0
pakprevnum = 0
rcvnum=0
while 1:
    # receive packet, blocking mode
    pktlen, sender = s.recvfrom_into(packet, PACKET_SIZE)
    # receive packet non-blocking
    #result = select.select([s],[],[])
    #pktlen, sender = result[0][0].recvfrom_into(packet, PACKET_SIZE)
    if not packet: 
        break
    # event received
    #print pktlen, sender
    rcvnum +=1
    if not (my_sender in sender):
      if verbose:
        print('Packet['+str(pktlen)+'] from '+str(sender))
      continue
    if pktlen == IDLE_LENGTH:
      if run_started:
        elapsed_sec = time.time() - start
        print('Run stopped, evLen= ' + str(pktlen))
        run_started = False
        report()
        if sfil and not sfil.closed:
          fpos = sfil.tell()
          txtout = 'Closed '+sfil.name+'['+str(fpos)+'] after '+str(round(elapsed_sec,1))+'s'
          print(txtout)
          sfil.close()
      else: 
          #print "FEM alive"
          sys.stdout.write('\rFEM alive '+str(rcvnum)+'\r')
          sys.stdout.flush()
          #time.sleep(1)
      continue
    if not run_started:
      expected_length = pktlen
      print('Run started, evLen= ' + str(pktlen))
      run_started = True
      events=0
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
    if raw_ethernet:
      paknum = packet[OFS+4]*256 + packet[OFS+5]
      pakmissed = paknum - pakprevnum -1
      pakprevnum = paknum
      if pakmissed < 0:
        pakmissed += 65536 # correct for 16-bit overflow
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
      missed_ev += 65536 # correct the counter for 16-bit overflow
    missed_events_since_last_report += missed_ev
    if raw_ethernet:
      missed_events_since_last_report += pakmissed
    current_time = time.time()
    difftime = int(current_time - start)
    if difftime >= olddifftime + delta_time:
      report()
      olddifftime = difftime
    if time_stamping:
      time_stamp = int(current_time)
      packet[OFS+17] = time_stamp&0xff
      packet[OFS+16] = (time_stamp>>8)&0xff
      #print('l:'+str(pktlen)+' h:'+binascii.hexlify(packet[OFS:OFS+20])
      #+' d:'+binascii.hexlify(packet[OFS+20:OFS+30])+' t:'+binascii.hexlify(packet[pktlen-8:pktlen]))

    if sfil and not sfil.closed:
            sfil.write(struct.pack('1i',pktlen)) # write out the packet length (this adds 5% of cpu occupancy)
            sfil.write(packet[:pktlen])

    if events >= max_events:
      print('Stopped after '+str(max_events)+' events')
      if sfil and not sfil.closed:
        sfil.close()
      break

s.close()
