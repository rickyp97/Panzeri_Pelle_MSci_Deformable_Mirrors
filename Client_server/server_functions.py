import os
import sys
sys.path.append('H:/Msci Project/deformable_mirrors/camera_stuff')
sys.path.append('H:/Msci Project/deformable_mirrors/GA code')

import numpy as np
import socket
import time
import pickle

import GAtest_december 
import SMXM7X


#picturesdirect = 'C:/Users/riccardo/Desktop'
picturesdirect = 'C:/Users/matte/Desktop/ServerData'

print("Setting up camera...")
camera = SMXM7X.Cam()
camera.OpenDevice(0)
camera.SetStreamMode(0)
camera.SetAllGain(0)
camera.SetExposure(19)
print("Camera set up!")

def shutdownserver(client):
     message = 'Server shutting down'
     client.send(message.encode())
     client.close()
     camera.CloseDevice()
     return

def makefolder(client):
    foldername = client.recv(1024).decode()
    if foldername == '...':
        print ('here')
        message = 'type folder name'
        client.send(message.encode())
        client.close()
        return
    folder_dir = picturesdirect + '/' + foldername
    print (folder_dir)
    if not os.path.exists(folder_dir):
        os.mkdir(folder_dir)
        message = 'folder created'
        client.send(message.encode())
    else:
        message = 'folder already exists'
        client.send(message.encode())
    client.close()
    return
        
def takesnap(client):
     #time.sleep(0.1)
     folder = client.recv(1024).decode()
     print(folder)
     #time.sleep(0.1)
     config = client.recv(1024).decode()
     print (config)
     filename = config + '_' + time.strftime("%H_%M_%S") + '.bmp'
     camera.SaveSnapshot(picturesdirect + "/" + folder + "/", filename)
     message = 'snap saved'
     client.send(message.encode())
     client.close()
     return

def runGA(client):
     max_iters = client.recv(1024).decode()
     print (max_iters)
     population_size = client.recv(1024).decode()
     print (population_size)
     num_parents = client.recv(1024).decode()
     print (num_parents)
     variability = client.recv(1024).decode()
     print (variability)
     initial_population_list = client.recv(1024)
     initial_population = np.array(pickle.loads(initial_population_list))
     print (initial_population, type(initial_population), initial_population.shape)
     GAtest_december.optimise(client, int(max_iters),int(population_size),int(num_parents),int(variability),initial_population)
     message = 'GA done\n'
     client.send(pickle.dumps(message))
     time.sleep(0.1)
     client.close()
     return
     
     
     
