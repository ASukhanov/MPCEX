#!/usr/bin/python
# usage: ./dqcapture.sh options
# Data recorder of the gigabit ethernet sream from MPCEX FEM
#
# OPTIONS:
#  -d	dump events
#  -w	write events to disk
#  -c	print cell IDs
#  -l   limit number of events (to 10000)

# Version 2 2015-12-02 CellId is not checked if zero, useful when only one chain present  
# Version 3 2015-12-29 -l option

data_directory = "/tmp/"
port = 1792  # where do you expect to get a msg?
bufferSize = 7000 # whatever you need
max_events = 0

import select, socket
import time
import datetime
import sys, getopt
import struct

ev_offset = 0
ev_hdr = []
sfil = None
run_started = -1
bytesin = 0.
rc = 0
events=0
writing_enabled = False
dump_enabled = False
dump_trailer = True
cellids = False # decode cell IDs
nerrlen=0
prevlen=0
errcnt=0
prev_errcnt=0
prev_cellid = 0
lock_count = 0
MAX_LOCK_COUNT = 10
expected_length = 0
delta_time=10
missed_ev = 0
prevnum = 0
nErrL1S = 0
nErrLPar = 0
nEmptyEvents = 0
lEmptyEvent = 28 # length of the empty event

# hex dump
#FILTER=''.join([(len(repr(chr(x)))==3) and chr(x) or '.' for x in range(256)])
def dump(src, length=16):
	N=0; result=''
	while src:
		s,src = src[:length],src[length:]
		hexa = ' '.join(["%02X"%ord(x) for x in s])
		#s = s.translate(FILTER)
		#result += "%04X   %-*s   %s\n" % (N, length*3, hexa, s)
		result += "%04X   %-*s\n" % (N, length*3, hexa)
		N+=length
	return result

def i16(b0,b1):
	return b0<<8 + b1

def lParity(src):
	# very slow longitudinal parity calculator
	#ii = 16
	lpar = 0
	while src:
		wrd = struct.unpack_from('>H',src[:2])
		src = src[2:]
		lpar ^= wrd[0]
	return lpar

prevev=0
missed_events_since_last_report = 0
def report():
  global prevev, missed_events_since_last_report
  txtout  = str(difftime)+'s, '
  txtout += hex(evnum)+' ev#'+str(events)+', evLen='+str(msglen)
  txtout += ' accepted: '+str((events-prevev)/delta_time)+'ev/s,'
  txtout += ' produced: '+str((events-prevev+missed_events_since_last_report)/delta_time)+'ev/s,'
  txtout += ' nErrLen='+str(nerrlen)+', nErrL1S='+str(nErrL1S)+', nCIDErr='
  prevev = events
  missed_events_since_last_report = 0
  if cellids:
          txtout += str(errcnt)
  else:
          txtout += '?'
  txtout += ', bytes in: '+str(bytesin) + ', out: '+str(bytesout)+'kB '
  print(txtout)

quiet = False
for opt in sys.argv:
	if opt == '-w':
		writing_enabled = True
		print('Writing enabled')
	if opt == '-d':
		dump_enabled = True
		print('Dump enabled')
	if opt == '-q':
		quiet = True
        if opt == '-c':
                print('Cell ID Decoding enabled')
		cellids = True
        if opt == '-l':
                max_events = 10000

s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
#s.bind(('<broadcast>', port))
s.bind(('255.255.255.255', port))
rc =  s.setsockopt(socket.SOL_SOCKET, socket.SO_RCVBUF, bufferSize)
s.setblocking(0)

while True:
	result = select.select([s],[],[])
	msg = result[0][0].recv(bufferSize)
	events +=1;
	msglen = len(msg)
	if msglen != prevlen and msglen != lEmptyEvent:
		if prevlen >0:
			nerrlen +=1;
	prevlen = msglen
	bytesin += msglen
	if run_started == -1:
		run_started = 0
		print('FEM is alive, msgLen=' + str(msglen))
	if msglen == 44:
		if run_started == 1:
			elapsed_sec = time.time() - start
			print('Run stopped, evLen= ' + str(msglen))
			run_started = 0
			report()
			if sfil and not sfil.closed:
				fpos = sfil.tell()
				txtout = 'Closed '+sfil.name+'['+str(fpos)+'] after '+str(round(elapsed_sec,1))+'s'
				print(txtout)
				sfil.close()
		continue
	elif run_started == 0:
		expected_length = msglen
		print('Run started, evLen= ' + str(msglen))
		run_started = 1
		bytesin = 0.
		if writing_enabled:
			filename = datetime.datetime.today().strftime("%y%m%d%H%M.dq4")
			sfil = open(data_directory+filename,'wb')
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

	# Process event
	if msglen < 100:
                if msglen == lEmptyEvent:
                  nEmptyEvents = nEmptyEvents + 1
                else:
		  print('ERROR short event '+str(msglen))
		  continue
        evnum = struct.unpack_from('>HH',msg)[0]
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
	if msglen != expected_length:
		nerrlen += 1
		if not quiet:
			print('ERROR in ev#'+str(evnum)+'. Unexpected length '+str(msglen)+' != '+str(expected_length))
		if cellids:
			continue

        l1stack=struct.unpack_from('>H',msg,2)
        #print('l1s[0]='+str(hex(l1stack[0])))
        l1s = l1stack[0] >> 12
        #print('l1s='+str(l1s))
        if l1s == 0 or l1s > 5:
           nErrL1S = nErrL1S + 1

        if cellids:
		if not quiet:
			print('ev'+hex(evnum).split('0x')[1].zfill(4)+':'),
		for ii in range(12):
                        wrd = struct.unpack_from('>HH',msg,2*(10+ii*258))
                        if ii == 0:
				cellid0 = wrd[0]
				#print('\ncellid='+str(cellid0))
                        #print('\ncellids='+str(wrd))
			for jj in range(2):
				if not quiet:
					print(hex(wrd[jj]).split('0x')[1].zfill(4)),
				if wrd[jj] != cellid0:
					if wrd[jj] != 0 or jj == 0: #Vers2
						errcnt +=1
		if errcnt != prev_errcnt and not quiet:
			print('_ERR#'+str(errcnt)),
		prev_errcnt = errcnt

		# lockup detection
		if wrd[0] == prev_cellid:
			lock_count += 1;
		else:
			lock_count = 0;
		if lock_count > MAX_LOCK_COUNT:
			print('\nCell Lockup at event '+hex(evnum-MAX_LOCK_COUNT)+'. '),
			print('Sleep 1s and continue'),
			time.sleep(1)
			#print('File closed'),
			#if sfil and not sfil.closed:
			#	sfil.close() 
			#exit(1)
		prev_cellid = wrd[00]
		if not quiet:
			print('\n'),
	if not cellids and not quiet:
                if msglen == lEmptyEvent:
                  ev_hdr = struct.unpack_from('>HHHHHHHHHH',msg,ev_offset*2)
                  l=10
                else:
                  ev_hdr = struct.unpack_from('>HHHHHHHHHHHHHHHHHHHHHH',msg,ev_offset*2)
                  l=22
		for ii in range(l):
			print(hex(ev_hdr[ii]).split('0x')[1].zfill(4)),
		evnum = ev_hdr[0]
                #l1stack = ev_hdr[1]
                #print('l1s='<<str(l1stack)),
		ev_trl = struct.unpack_from('>HHHH',msg[-8:])
		print('...'),
		for ii in range(4):
			print(hex(ev_trl[ii]).split('0x')[1].zfill(4)),
		print('LPar='+hex(lParity(msg))),
		print('L='+str(msglen)),
                if nErrL1S:
                  print('_ERRL1S#'+str(nErrL1S)),
		#print('missed='+str(missed_ev)+','+str(missed_events_since_last_report))
                print('.')
	if dump_enabled:
		print(dump(msg))
	if sfil and not sfil.closed:
		sfil.write(struct.pack('1i',msglen))
		sfil.write(msg)
	difftime = int((time.time() - start))
	if sfil and not sfil.closed:
		bytesout = round(sfil.tell()/1000.,1) 
	else:
		bytesout = 0.
	#if difftime/delta_time != olddifftime/delta_time:
        if difftime >= olddifftime + delta_time:
          report()
          olddifftime = difftime
        if max_events > 0:
          if events >= max_events:
            print('Stopped after '+str(max_events))
            if sfil and not sfil.closed:
              sfil.close()
            break
