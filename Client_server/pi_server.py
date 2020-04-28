import socket               
from datetime import datetime
import os
import pi_server_functions as servfunc
import pickle    

s = socket.socket()         # Create a socket object
#s.settimeout(100)          #set timeout
host = '192.168.137.117'          # Get pc ip address
port = 12345                # Reserve a port for your service.
s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR,1)

s.bind((host, port))        # Bind to the port
s.listen(2)     
while True:
    print("waiting for connection...")
    c, addr = s.accept()     # Establish connection with client.
    l=c.recv(1024)
    l = pickle.loads(l)
    print (l)
    if l == 'config':
        servfunc.setconfig(c)
    elif l == "config_all":
        servfunc.setconfig_all(c)                       
#    elif l == 'runGA':
#        servfunc.runGA(c)
    elif l == 'stop':
        servfunc.shutdownserver(c)
        break
    else:   
       continue 
print ('out')
s.shutdown(socket.SHUT_RDWR)
s.close()
