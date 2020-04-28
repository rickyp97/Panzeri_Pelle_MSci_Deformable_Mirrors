import socket               # Import socket module
import pickle
import numpy as np

host = '192.168.137.117'          # Get server address
port = 12345                # Reserve a port for your service.

def sendconfig(valuelist, channellist, Daclist, valueflag, fastoff = "Off", host = host, port = port):  #vlues, channels and dacs should be ordered lists of same lenght
    socketname = socket.socket()
    socketname.settimeout(15)
    socketname.connect((host,port))
    string = 'config'
    socketname.send(pickle.dumps(string))
    #print ('sending')
    
    #convert setting to appropriate value
    valuelist = [int(i) for i in valuelist]
    #print(type(valuelist), type(valuelist[0]))
    #print(type(valuelist), type(valuelist[0]))
    
    #socketname.send(pickle.dumps(valuelist)+pickle.dumps(channellist)+pickle.dumps(Daclist)+pickle.dumps(valueflag))
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

def send_all_config(valuelist,channellist,Daclist,valueflag,fastoff, host = host, port = port): 
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

def sendstop(host = host, port = port):
    string = 'stop'
    socketname = socket.socket()
    socketname.settimeout(15)
    socketname.connect((host,port))
    socketname.send(pickle.dumps(string))
    bye = socketname.recv(1024)
    bye_message = pickle.loads(bye)
    print(bye_message)
    return 
    

#def GAstuff(max_iters, pop_size, num_parents,variability, init_pop,host = host,port = port):
#    socketname = socket.socket()
#    socketname.settimeout(30)
#    socketname.connect((host,port))
#    socketname.send('runGA'.encode())
#    time.sleep(0.05)
#    socketname.send(max_iters.encode())
#    time.sleep(0.1)
#    socketname.send(pop_size.encode())
#    time.sleep(0.1)
#    socketname.send(num_parents.encode())
#    time.sleep(0.1)
#    socketname.send(variability.encode())
#    time.sleep(0.1)
#    init_pop_bit = pickle.dumps(init_pop)
#    socketname.send(init_pop_bit)
#    time.sleep(0.1)
#    GAloop(max_iters, pop_size, socketname)
#    socketname.close()                
#    return
#
#def GAloop(max_iters, pop_size, socket):
#    tot_iters = int(max_iters)*int(pop_size) + int(max_iters)
#    counter = 0
#    while True: 
#        config_enc = socket.recv(1024)
#        config = pickle.loads(config_enc)
#        if isinstance(config, str):
#            socket.send('out'.encode())
#            break
#        config = list(config)
#        for i in range(len(config)):
#            dac.setValue(dac.DAC1,i+1,int(config[i]))
#        counter += 1
#        print ("%i/%i" %(counter,tot_iters))
#        time.sleep(1.1)
#        socket.send('config set'.encode())
#        
#    return
