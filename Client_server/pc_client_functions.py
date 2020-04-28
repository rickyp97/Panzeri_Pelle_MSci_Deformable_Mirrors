''' This module contains the functions used by the pc to communicate with the pi. Ideally these functions are used from the GUI, or from the optimisation modules'''


import socket               # Import socket module
import pickle
#import numpy as np

host = '192.168.137.117'          # Get server address (IP of Pi)
port = 12345                # Reserve a port for your service (same as port reserved on Pi).

def sendconfig(valuelist, channellist, Daclist, valueflag, fastoff = "Off", host = host, port = port):  #values, channels and dacs should be ordered lists of same lenght (for dacs use list of 'DAC1', like ['DAC1', 'DAC1'])...fastoff can be 'off' or 'on'.
    socketname = socket.socket()
    socketname.settimeout(15)
    socketname.connect((host,port))
    string = 'config'
    socketname.send(pickle.dumps(string))
    
    #convert values to appropriate integer format
    valuelist = [int(i) for i in valuelist]

    msg = [valuelist, channellist, Daclist, valueflag, fastoff]
    socketname.send(pickle.dumps(msg))
    #print(type(valuelist), type(valuelist[0]))
    #print(type(channellist), type(channellist[0]))
    #print(pickle.dumps(valuelist))
    #print(pickle.dumps(channellist))
    #print(pickle.dumps(Daclist))
    #print(pickle.dumps(valueflag))
    #print ('done sending')
    print(pickle.dumps(msg))
    bye = socketname.recv(1024)
    bye_message = pickle.loads(bye)
    socketname.close()
    return bye_message

def send_all_config(valuelist,channellist,Daclist,valueflag,fastoff, host = host, port = port): #same as above, but sends all 5 channels 
    socketname = socket.socket()
    socketname.settimeout(15)
    socketname.connect((host,port))
    string = 'config_all'
    socketname.send(pickle.dumps(string))
    valuelist = [int(i) for i in valuelist]
    msg = [valuelist, channellist, Daclist, valueflag, fastoff]
    socketname.send(pickle.dumps(msg))
    print(pickle.dumps(msg))
    bye = socketname.recv(1024)
    bye_message = pickle.loads(bye)
    socketname.close()
    return bye_message

def sendstop(host = host, port = port):  # sendstop closes the server
    string = 'stop'
    socketname = socket.socket()
    socketname.settimeout(15)
    socketname.connect((host,port))
    socketname.send(pickle.dumps(string))
    bye = socketname.recv(1024)
    bye_message = pickle.loads(bye)
    print(bye_message)
    return 
    


