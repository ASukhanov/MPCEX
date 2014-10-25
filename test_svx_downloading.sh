
gpio -g write 8 0
Play_stapl.py i1c 1
gpio -g write 8 1
Play_stapl.py -c i30 100

gpio -g write 8 0
Play_stapl.py i1c 2
gpio -g write 8 1
Play_stapl.py -c i30 100

gpio -g write 8 0
Play_stapl.py i1c 4
gpio -g write 8 1
Play_stapl.py -c i30 100

gpio -g write 8 0
Play_stapl.py i1c 8
gpio -g write 8 1
Play_stapl.py -c i30 100

# Do downloading
gpio -g write 8 0

Play_stapl.py i10 10100
StaplPlayer -aTRANS svxall.stp

Play_stapl.py i10 10210
StaplPlayer -aTRANS svxall.stp

Play_stapl.py i10 10420
StaplPlayer -aTRANS svxall.stp

Play_stapl.py i10 10830
StaplPlayer -aTRANS svxall.stp

