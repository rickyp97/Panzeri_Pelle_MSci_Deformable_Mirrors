''' This is the code that has to be run on the Pi. Simply run this module and the client should be able to connect and send requests.
It needs the module pi_server_functions which needs to be imported. This code runs in loop until shut down from the client or interrupted
by force (might need to close the kernel if it gets stuck)
'''

import socket               
from datetime import datetime
import os
import pi_server_functions as servfunc
import pickle    

s = socket.socket()         # Create a socket object
#s.settimeout(100)          #set timeout
host = '192.168.137.117'          # Pi ip address, the same that will be written on pc_client_functions
port = 12345                # Reserve a port for your service. same that will be written in pc_client_functions
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
    elif l == 'stop':
        servfunc.shutdownserver(c)
        break
    else:   
       continue 
print ('out')
s.shutdown(socket.SHUT_RDWR)
s.close()
