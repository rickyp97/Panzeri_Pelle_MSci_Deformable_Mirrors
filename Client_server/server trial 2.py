import socket               
from datetime import datetime
import os
import server_functions as servfunc

#from threading import Thread

#class client(Thread):
#    def __init__(self, socket, address):
#        Thread.__init__(self)
#        self.sock = socket
#        self.addr = address
#        self.start()
#    
#    def run(self):
#        l=self.sock.recv(1024).decode()
#        x=0
#        while x < len(l):
#            print (x)
#            x=x+1
#        print('done')
#        return
#        
        

s = socket.socket()         # Create a socket object
#s.settimeout(100)          #set timeout
host = '192.168.137.1'          # Get pc ip address
port = 12345                # Reserve a port for your service.
s.bind((host, port))        # Bind to the port
s.listen(2)     
while True:
    print("waiting for connection...")
    c, addr = s.accept()     # Establish connection with client.
    l=c.recv(1024).decode()
    print (l)
    if l == 'choosefolder':
        servfunc.makefolder(c)
    elif l == 'takesnap':
        servfunc.takesnap(c)
    elif l == 'runGA':
        servfunc.runGA(c)
    elif l == 'stop':
        servfunc.shutdownserver(c)
        break
    else:
        Picturename = l + '_' + str(datetime.time(datetime.now()))
        print (Picturename)        #INSERT FUNCTION THAT TAKES SNAPSHOT                            
        fitness = '10023'                #INSERT FITNESS FUNCTION HERE
        c.send(fitness.encode())
        thanks_message = c.recv(1024).decode()
        print (thanks_message)
        c.close()    
print ('out')    
s.close()
