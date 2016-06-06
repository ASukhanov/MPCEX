import socket
#UDP_IP = "255.255.255.255"
UDP_IP = "192.168.0.72"
UDP_PORT = 1792
message = "12345678901234567890"

sock = socket.socket(socket.AF_INET, # Internet
                     socket.SOCK_DGRAM) #UDP

for ii in range(10): 
  sock.sendto(message, (UDP_IP, UDP_PORT))
