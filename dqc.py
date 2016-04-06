#!/usr/bin/python
'''
    Simple udp socket server
'''
 
import socket
import sys
import struct
import binascii
 
HOST = ''   # Symbolic name meaning all available interfaces
#HOST = '255.255.255.255'
PORT = 1792 # FEM port

DATSIZE = 7000
data = bytearray(DATSIZE);

sender_prev=''
 
# Datagram (udp) socket
try :
    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    print ('Socket created')
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

while 1:
    # receive data
    datlen, sender = s.recvfrom_into(data, DATSIZE)
    if not data: 
        break
    if (sender != sender_prev):
      sender_prev = sender
      print('Data from '+str(sender))
    print('l:'+str(datlen)+' h:'+binascii.hexlify(data[:20])+' d:'+binascii.hexlify(data[20:30])+' t:'+binascii.hexlify(data[datlen-8:datlen]))

s.close()
