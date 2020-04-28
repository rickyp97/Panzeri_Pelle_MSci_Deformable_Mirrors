# -*- coding: utf-8 -*-

"""
Created on Mon Jan 13 17:36:22 2020

@author: Matteo Panzeri
"""
import numpy as np
import time
import datetime
from PIL import Image
import fitness_functions

# %% Genetic Algorithm
def optimise(f,data_directory,x0,max_iters,population_size,num_parents,variability):
    time_start = datetime.datetime.now()
    t0 = time.time()
    
    #initialize algorithm
    generation = 0
    n_dof = len(x0)
    num_offspring = population_size - num_parents
    
    # init population
    print("Initialising population...")
    x0 = np.array(x0)
    population = np.repeat(x0, population_size).reshape(n_dof, population_size).transpose()
    population += np.random.randint(-variability/2,variability/2, size=population.shape)
    population[population>4095] = 4095
    population[population<0] = 0
    timestr = time.strftime("%d_%m_%Y-%H_%M_%S")
    
    #create data logs
    file_data = open(data_directory + "GA_data_%s.csv" % timestr, 'w')
    file_data.write("f,max_iters,population_size,num_parents,variability,exposure,x0[0],x0[1],x0[2],x0[3],x0[4]\n")
    file_data.write("%a,%i,%i,%i,%f,%f,%i,%i,%i,%i,%i\n"%(f,max_iters,population_size,num_parents,variability,fitness_functions.exposure,x0[0],x0[1],x0[2],x0[3],x0[4]))
    file_data.write("t,generation,gene#,fitness,variability,I_total,I_max,x[0],x[1],x[2],x[3],x[4]\n")
    
    #save pic of initial config
    try:
        img_0 = Image.fromarray(fitness_functions.get_image())
        img_0.save(data_directory+"x0_%i_%i_%i_%i_%i.jpg"%tuple(x0))
    except:
        print("shfkjshgfdkjshdfkjhs")
    
    #core optimisation loop
    for generation in range(max_iters):
        # compute fitness
        print("Evaluating generation %d ..." % generation)
        fitness = np.array([f(s) for s in population])
        idx = np.argmax(fitness)
        print("Best solution:\n", population[idx])
        print("Best fitness: %f" % fitness[idx])
        
        #take snap of best fitness
        try:
            setting = population[idx]
            fitness_functions.send_setting(setting)
            img = fitness_functions.get_image()
            I_total = np.sum(img)
            I_max = np.amax(img)
            img = Image.fromarray(img)
            img.save(data_directory+"%i_%i_%i_%i_%i.jpg" % tuple(setting))
        except:
            I_total=-1
            I_max=-1
        
        #log data
        t = time.time() - t0
        srtd = np.argsort(fitness)
        for i,p in enumerate(population[srtd][::-1]):
            file_data.write("%f,%i,%i,%f,%f,%i,%i,%i,%i,%i,%i,%i\n"%(t,generation,i,fitness[srtd][::-1][i],variability*0.1**(generation/max_iters),I_total,I_max,p[0],p[1],p[2],p[3],p[4]))
        file_data.flush()
        
        if (generation == max_iters-1):
            break
        
        #generate new population
        print("Generating new population...")
        parents = select_parents(fitness, population, num_parents)
        offspring = crossover(parents, num_offspring)
        offspring = mutate(offspring, variability*0.1**(generation/max_iters))
        population = np.vstack((parents, offspring))
        generation +=1
    
    print("Iteration stopped")
    print("time elapsed:", datetime.datetime.now()-time_start)
    file_data.close()
    return population[idx], fitness[idx]

def select_parents(fitness, population, num_parents):
    # rank genes from best to worst
    srtd = np.argsort(fitness)
    parents = population[srtd][::-1]
    # select the [num_parents] fittest genes in the population
    return parents[:num_parents]

def crossover(parents, num_offspring):
    #create offspring by crossing over parents at mid-point
    num_parents = parents.shape[0]
    n_dof = parents.shape[1]
    crossover_point = np.uint16(0.5*n_dof)
    offspring = np.zeros((num_offspring, n_dof))
    
    for k in range(num_offspring):
        p_1 = np.random.randint(num_parents)
        p_2 = np.random.randint(num_parents)
        offspring[k,:crossover_point] = parents[p_1,:crossover_point]
        offspring[k,crossover_point:] = parents[p_2,crossover_point:]
        
    return offspring

def mutate(offspring,variability):
    #add a random integer between +/- variability/2 to each gene
    offspring = offspring +  np.random.randint(-variability/2,variability/2,size=offspring.shape) 
    #correct  out of bounds values
    offspring[offspring < 0] = 0
    offspring[offspring > 4095] = 4095
    return offspring
    
