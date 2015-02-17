#!/usr/bin/python
# hex dump of the SPlayer output
import sys

ii=0
for pline in sys.stdin:
	try:
        	line = pline.split('HEX ')[1][:8]
		if(len(line)!=8):
			continue
                if ii%8 == 0:
                        print(hex(ii).zfill(6) + ': '),
		print(line),
		ii += 1
		if ii%8 == 0:
			print('')
	except:
		exit()
