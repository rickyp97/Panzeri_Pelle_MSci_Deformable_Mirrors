import socket               # Import socket module
import time
import pickle

import sys
sys.path.append('/home/pi/deformable_mirrors')
import DAC_control_v1 as dac


s = socket.socket()         # Create a socket object
host = '192.168.137.1'          # Get server address
port = 12345                # Reserve a port for your service.

def sendconfig(string, host = host, port = port):
    socketname = socket.socket()
    socketname.settimeout(15)
    socketname.connect((host,port))
    print ('sending')
    socketname.send(string.encode())
    print ('done sending')
    fitness = socketname.recv(1024).decode()
    bye_message = 'Fitness received'
    socketname.send(bye_message.encode())
    socketname.close()
    return print (fitness)

def sendstop(host = host, port = port):
    string = 'stop'
    socketname = socket.socket()
    socketname.settimeout(15)
    socketname.connect((host,port))
    socketname.send(string.encode())
    bye_message = socketname.recv(1024).decode()
    print(bye_message)
    return 
    
def folderselect(foldername, host = host, port = port):
    socketname = socket.socket()
    socketname.settimeout(15)
    socketname.connect((host,port))
    socketname.send('choosefolder'.encode())
    time.sleep(0.01)
    socketname.send(foldername.encode())
    bye_message = socketname.recv(1024).decode()
    print (bye_message)
    return

def snaprequest(foldername, config, host = host, port= port):
    socketname = socket.socket()
    socketname.settimeout(30)
    socketname.connect((host,port))
    socketname.send('takesnap'.encode())
    time.sleep(0.15)
    socketname.send(foldername.encode())
    time.sleep(0.15)
    socketname.send(config.encode())
    bye_message = socketname.recv(1024).decode()
    print(bye_message)
    return

def GAstuff(max_iters, pop_size, num_parents,variability, init_pop,host = host,port = port):
    socketname = socket.socket()
    socketname.settimeout(30)
    socketname.connect((host,port))
    socketname.send('runGA'.encode())
    time.sleep(0.05)
    socketname.send(max_iters.encode())
    time.sleep(0.1)
    socketname.send(pop_size.encode())
    time.sleep(0.1)
    socketname.send(num_parents.encode())
    time.sleep(0.1)
    socketname.send(variability.encode())
    time.sleep(0.1)
    init_pop_bit = pickle.dumps(init_pop)
    socketname.send(init_pop_bit)
    time.sleep(0.1)
    GAloop(max_iters, pop_size, socketname)
    socketname.close()                
    return

def GAloop(max_iters, pop_size, socket):
    tot_iters = int(max_iters)*int(pop_size) + int(max_iters)
    counter = 0
    while True: 
        config_enc = socket.recv(1024)
        config = pickle.loads(config_enc)
        if isinstance(config, str):
            socket.send('out'.encode())
            break
        config = list(config)
        for i in range(len(config)):
            dac.setValue(dac.DAC1,i+1,int(config[i]))
        counter += 1
        print ("%i/%i" %(counter,tot_iters))
        time.sleep(1.1)
        socket.send('config set'.encode())
        
    return
