import os
import traceback
import sys

sys.path.append('/home/pi/deformable_mirrors/GA_code')

import sys
sys.path.append('/home/pi/deformable_mirrors/Pi_code')
#import DAC_control_v1 as dac
import DAC_control_v2_fast_off as dac

import numpy as np
import socket
import time
import pickle

#import GAtest_december 

#picturesdirect = 'C:/Users/riccardo/Desktop'
picturesdirect = 'C:/Users/matte/Desktop/ServerData'

def setconfig(client):  
    try:
        bits = client.recv(4096)
        l = pickle.loads(bits)
        print(l)
        values = l[0]
        channels = l[1]
        Dac = l[2]
        valueflag = l[3]
        fastoff = l[4]
        #l = bits.split(b'.')
        #values = pickle.loads(l[0]+b'.')
        #channels = pickle.loads(l[1]+b'.')
        #Dac = pickle.loads(l[2]+b'.')
        #valueflag = pickle.loads(l[3]+b'.')
        
        print(values,channels,Dac,valueflag)
        for n in range(len(channels)):
            if Dac[n] == 'DAC1':
                board = dac.DAC1
            elif Dac[n] == 'DAC2':
                board == dac.DAC2
            if valueflag == "Voltage":
                dac.setVoltage(board, int(channels[n]), int(values[n]), fastoff)
                print("voltage is" , values[n], 'on', channels[n])
            elif valueflag == "Duty":
                dac.setValue(board, channels[n], values[n],fastoff)
                print("duty is", values[n], 'on', channels[n])
            else:
                raise ValueError
        bye = pickle.dumps('config set')
        client.send(bye)
        client.close()        
        return
    except Exception as ex:
        print (ex)
        print(traceback.format_exc())
        print("LOLOLOL")
        bye = pickle.dumps('something went wrong')
        client.send(bye)
        client.close()
        return
    
def setconfig_all(client):
    try:
        bits = client.recv(4096)
        l = pickle.loads(bits)
        print(l)
        values = l[0]
        channels = l[1]
        # Dac = l[2]
        # valueflag = l[3]
        fastoff = l[4]
        dac.setValue_all(dac.DAC1,channels,values,fastoff)
        bye = pickle.dumps('config set')
        client.send(bye)
        client.close()
        return
    except Exception as ex:
        print (ex)
        print(traceback.format_exc())
        print("LOLOLOL")
        bye = pickle.dumps('something went wrong')
        client.send(bye)
        client.close()
        return
def shutdownserver(client):                 
     message = 'Server shutting down'
     client.send(pickle.dumps(message))
     client.close()
     return

#def runGA(client):
#     max_iters = client.recv(1024).decode()
#     print (max_iters)
#     population_size = client.recv(1024).decode()
#     print (population_size)
#     num_parents = client.recv(1024).decode()
#     print (num_parents)
#     variability = client.recv(1024).decode()
#     print (variability)
#     initial_population_list = client.recv(1024)
#     initial_population = np.array(pickle.loads(initial_population_list))
#     print (initial_population, type(initial_population), initial_population.shape)
#     GAtest_december.optimise(client, int(max_iters),int(population_size),int(num_parents),int(variability),initial_population)
#     message = 'GA done\n'
#     client.send(pickle.dumps(message))
#     time.sleep(0.1)
#     client.close()
#     return
