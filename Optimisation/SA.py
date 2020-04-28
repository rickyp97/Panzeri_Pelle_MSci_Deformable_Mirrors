"""
Created on Mon Jan 13 17:36:22 2020

@author: Matteo Panzeri
"""
import numpy as np
import time
import datetime
from PIL import Image
import fitness_functions

# %% Simulated Annealing algorithm
def optimise(f,data_directory,x0,max_iters,T0,step_size):
    time_start = datetime.datetime.now()
    
    #initialise algorithm
    x=np.array(x0)
    E=f(x)
    x_best = x
    E_best = E
    T=T0
    I_total = 0
    I_max = 0
    
    t0 = time.time()
    
    #save pic of initial config
    img_0 = Image.fromarray(fitness_functions.get_image())
    img_0.save(data_directory+"x0_%i_%i_%i_%i_%i.jpg"%tuple(x0))
    
    #datalog
    timestr = time.strftime("%d_%m_%Y-%H_%M_%S")
    file_data = open(data_directory + "SA_data_%s.csv" % timestr, 'w')
    file_data.write("f,E0,max_iters,T0,step_size,exposure,x0[0],x0[1],x0[2],x0[3],x0[4]\n")
    file_data.write("%a,%f,%i,%f,%i,%f,%i,%i,%i,%i,%i\n"%(f,E,max_iters,T0,step_size,fitness_functions.exposure,x0[0],x0[1],x0[2],x0[3],x0[4]))
    file_data.write("i,t,energy,T,I_total,I_max,x[0],x[1],x[2],x[3],x[4]\n")
    file_data.flush()
    
    #core optimisation loop
    for i in range(max_iters):
        print(i/max_iters*100,"%")
        #compute new temperature
        T = temperature(i/max_iters,T0)
        
        #take a step and compute energy
        x_new = neighbour(x,step_size)
        E_new = f(x_new)
        
        #update best for algorithm restarts
        if E_new > E_best:
            E_best = E_new
            x_best = x_new
        
        #compute acceptance
        if accept(E,E_new,T):
            x = x_new
            E = E_new
            # TAKE PIC
            fitness_functions.send_setting(x)
            img = fitness_functions.get_image()
            I_total = np.sum(img)
            I_max = np.amax(img)
            img = Image.fromarray(img)
            img.save(data_directory+"%i_%i_%i_%i_%i.jpg" % tuple(x))
    
        #log data
        t = time.time() - t0
        file_data.write("%i,%f,%f,%f,%i,%i,%i,%i,%i,%i,%i\n" % (i,t,E,T,I_total,I_max,x[0],x[1],x[2],x[3],x[4]))
        file_data.flush()
    
    print("Iteration stopped")
    print("time elapsed:", datetime.datetime.now()-time_start)
    file_data.close()
    return x,E,x_best,E_best

def temperature(frac,T0):
    return T0*0.1**frac

def neighbour(x,step_size):
    x_new = x + np.random.randint(-step_size/2, step_size/2, size = x.shape)
    x_new[x_new > 4095] = 4095
    x_new[x_new < 0] = 0
    return x_new

def accept(E,E_new,T):
    if E_new > E:
        return True
    
     p = np.exp(-(E-E_new)/T)
     if p >= np.random.uniform(0,1):
         return True
     else:
         return False
