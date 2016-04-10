#!/usr/bin/python
version = "v1 2016-04-06. "
def usage():
  print('Simple udp receiver. '+version+\
    'usage: '+sys.argv[0]+ ' -v/-w')
 
import socket
import time
import sys
import struct
import binascii
import getopt
 
HOST = ''   # Symbolic name meaning all available interfaces
#HOST = '255.255.255.255'
PORT = 1792 # FEM port

PACKET_SIZE = 7000
packet = bytearray(PACKET_SIZE);
sender_prev=''
events=0
delta_time=10

prevev=0
missed_events_since_last_report = 0
def report():
  global prevev, missed_events_since_last_report
  txtout  = str(difftime)+'s, '
  txtout += hex(evnum)+' ev#'+str(events)+', evLen='+str(pktlen)
  txtout += ' accepted: '+str((events-prevev)/delta_time)+'ev/s,'
  txtout += ' produced: '+str((events-prevev+missed_events_since_last_report)/delta_time)+'ev/s,'
  #txtout += ' nErrLen='+str(nerrlen)+', nErrL1S='+str(nErrL1S)+', nCIDErr='
  prevev = events
  missed_events_since_last_report = 0
  #txtout += ', bytes in: '+str(bytesin) + ', out: '+str(bytesout)+'kB '
  print(txtout)

try:
  opts,args = getopt.getopt(sys.argv[1:], 'hwvn:', ["help", "write to disk", "verbose", "n="])
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
            print("Writing Enabled")
        elif o in ("-n", "--number"):
            print("Number="+a)
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
    events +=1;
    evnum = packet[0]*256 + packet[1]
    #print('e:'+str(evnum))
    if verbose:
      print('l:'+str(pktlen)+' h:'+binascii.hexlify(packet[:20])+' d:'+binascii.hexlify(packet[20:30])+' t:'+binascii.hexlify(packet[pktlen-8:pktlen]))
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
    '''
    if sfil and not sfil.closed:
            bytesout = round(sfil.tell()/1000.,1)
    else:
            bytesout = 0.
    '''
    #if difftime/delta_time != olddifftime/delta_time:
    if difftime >= olddifftime + delta_time:
      report()
      olddifftime = difftime

s.close()
