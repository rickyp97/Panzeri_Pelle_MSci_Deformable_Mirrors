''' functions used by pi_server. as these are the ones that send outputs to the DAC from the Pi, it needs one of the DAC_control files,
either v1 or fast_off. they need to be imported, so either put them in the same folder or add the folder path.'''


import traceback

import sys
sys.path.append('folder path')    #use this to add the path to the folder where the DAC_control file is 
#import DAC_control_v1 as dac
import DAC_control_fast_off as dac   #use this module, which has the fast-off mode implemented. if you are not using fast off, the fastoff argument taken by some functions should be 'off'.

import numpy as np
import socket
import pickle

def setconfig(client):          #sets the values received from the client on the DAC
    try:
        bits = client.recv(4096)
        l = pickle.loads(bits)
        print(l)
        values = l[0]
        channels = l[1]
        Dac = l[2]
        valueflag = l[3]
        fastoff = l[4]
        
        print(values,channels,Dac,valueflag)
        for n in range(len(channels)):
            if Dac[n] == 'DAC1':            # always use 'DAC1' until you have added more DACs 
                board = dac.DAC1
            elif Dac[n] == 'DAC2':
                board == dac.DAC2
            if valueflag == "Voltage":      # if you are giving values as voltages
                dac.setVoltage(board, int(channels[n]), int(values[n]), fastoff)
                print("voltage is" , values[n], 'on', channels[n])
            elif valueflag == "Duty":           # if you are giving values as duty cycle 0-4095
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
    
def setconfig_all(client):  #sends all the configs received from the client to the DAC.
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
        bye = pickle.dumps('something went wrong')
        client.send(bye)
        client.close()
        return
    
def shutdownserver(client):                 #closes the server, which stops running
     message = 'Server shutting down'
     client.send(pickle.dumps(message))
     client.close()
     return

