# -*- coding: utf-8 -*-
"""
Created on Fri Jan 31 16:31:24 2020

@author: Matteo Panzeri

Code which implements 4 fitness functions. Code takes a DM setting as a list of 5 integers as input and returns value of fitness.
The code uses the pc_client_functions module to communicate with the Raspberry Pi and the SMXM7X module to communicate with the camera.
Make sure that BOTH the SMXM7X.pyd and the SMXM7X.dll files are present in the directory containing this script, and that you are running this in 32-bit python
"""

import time
import numpy as np
from PIL import Image
import scipy.optimize as opt
import sys
sys.path.append('../Client_server') #use this to tell python where to find the pc_client_functions module
import pc_client_functions


# Set up the SMXM7X camera
print("Importing SMXM7X module...")
try:
    import SMXM7X
except Exception as ex:
    print("Error while importing SMXM7X! N.B. you need to run this script in 32-bit python")
    raise(ex)
print("Imported!")
print("Setting up camera...")
camera = SMXM7X.Cam()
camera.OpenDevice(0)
exposure = camera.SetExposure(2)
print(camera.GetCameraInfo())
frameParams = camera.GetFrameParams()
width = frameParams['Width']
height = frameParams['Height']
print(camera.GetFrameParams())
print("Done!")

# send a mirror setting to the Raspberry Pi
def send_setting(setting):
    print("sending setting:", setting)
    channels = list(range(1,len(setting)+1))  #send to first n channels
    DAClist = ["DAC1"]*len(setting)
    pc_client_functions.send_all_config(list(setting), channels, DAClist, "Duty", "On")
    time.sleep(0.5)
    return

#crop image around centre
def crop_image(img,w):
    #compute image centre using marginal distributions
    x_distr_marginal = np.sum(img,axis=0)/np.sum(img)
    y_distr_marginal = np.sum(img,axis=1)/np.sum(img)
    c = (np.argmax(x_distr_marginal),np.argmax(y_distr_marginal))
    img_cropped = img[c[1]-w:c[1]+w+1, c[0]-w:c[0]+w+1]
    return img_cropped

#take a picture from the camera, cropping and averaging
def get_image(n_avg=10,w=300):
    #average over a few images
    img_sum = np.zeros((2*w+1,2*w+1), dtype=np.uint64)
    for i in range(n_avg):
        img = np.array(Image.fromarray(camera.GetSnapshot()).convert('LA'))[:,:,0]
        img_sum += crop_image(img,w)
        
    img_avg = img_sum/n_avg
    img_avg = img_avg.astype(np.uint8)
    #image_grayscale = np.array(Image.fromarray(img_avg).convert('LA'))[:,:,0]
    return img_avg

# fitness function using cumulative intensity distribution
def cumulative_distribution(setting):
    #send setting and retrieve image
    try:
        send_setting(setting)
        img = get_image()
    except:
        return 0
    
    #compute centre and crop image
    x_distr_marginal = np.sum(img,axis=0)/np.sum(img)
    y_distr_marginal = np.sum(img,axis=1)/np.sum(img)
    c = (np.argmax(x_distr_marginal),np.argmax(y_distr_marginal))
    w=250
    image_cropped = img[c[1]-w:c[1]+w+1, c[0]-w:c[0]+w+1]
    
    #compute distance array
    x = np.arange(-image_cropped.shape[0]/2,image_cropped.shape[0]/2)
    xx,yy = np.meshgrid(x,x)
    distance = np.sqrt(xx**2+yy**2).astype(np.int)
    
    #debug check on cropped image shape
    if image_cropped.shape != (2*w+1,2*w+1):
        print("&&&&&&&&&&&&&&&SHAPE FUCKED UP&&&&&&&&&&&&&&&&&&&&&&&")
        return 0
    
    #compute radial intensity distribution
    radial_intensity = []
    for r in np.unique(distance):
        grays = image_cropped[distance == r]
        radial_intensity.append(np.mean(grays))

    #return fitness
    return(np.trapz(np.cumsum(radial_intensity)))#/np.amax(np.cumsum(radial_intensity))))

# Fitness function using numerical methods to compute focal spot effective area
def intensity_central(setting):
    try:
        send_setting(setting)
        img = get_image()
    except:
        print("##############\nAn exception occurred while calculating numerical fitness!\n##############")
        return 0
    
    #compute image centre using marginal distributions
    return intensity_central_img(img)

def intensity_central_img(img):
    #compute image centre using marginal distributions
    x_distr_marginal = np.sum(img,axis=0)/np.sum(img)
    y_distr_marginal = np.sum(img,axis=1)/np.sum(img)
    c = (np.argmax(x_distr_marginal),np.argmax(y_distr_marginal))
    x_distr_central = img[c[1],:]/np.sum(img[c[1],:])
    y_distr_central = img[:,c[0]]/np.sum(img[:,c[0]])
    
    #compute variance
    x = np.arange(img.shape[1])
    y = np.arange(img.shape[0])
    mu_x = np.sum(x_distr_central*x)
    mu_y = np.sum(y_distr_central*y)
    var_x = np.sum(x_distr_central*x**2)-mu_x**2
    var_y = np.sum(y_distr_central*y**2)-mu_y**2
    FWHM_x = 2*np.sqrt(2*np.log(2))*np.sqrt(var_x)
    FWHM_y = 2*np.sqrt(2*np.log(2))*np.sqrt(var_y)
    
    fitness = np.sum(img)/(FWHM_x*FWHM_y)
    return fitness

def gaussian(x,A,mu,sigma):
    return A*np.exp(-((x-mu)**2/(2*(sigma)**2)))

# Fitness functions using gaussian fit to compute effective area
def fitness_gaussian(setting):
    #send setting and retrieve image
    try:
        send_setting(setting)
        img = get_image()
    except:
        print("##############\nAn exception occurred while calculating gaussian fitness!\n##############")
        return 0
    
    #compute image centre using marginal distributions
    return fitness_gaussian_img(img)

def fitness_gaussian_img(img, return_all = False):
    try:
        w = int((img.shape[0]-1)/2)
        x_line = img[w+1,:]
        y_line = img[:,w+1]
        
        x = np.arange(2*w+1)
        initial_param_x = [x_line[w+1], w+1,30]
        initial_param_y = [y_line[w+1], w+1,30]
        x_params, cov = opt.curve_fit(gaussian,x,x_line,initial_param_x)
        y_params, cov = opt.curve_fit(gaussian,x,y_line,initial_param_y)
        I_total = np.sum(img)
        I_max = np.amax(img)
        Amplitude_x = x_params[0]
        Amplitude_y = y_params[0]
        FWHM_x = 2*np.sqrt(2*np.log(2))*x_params[2]
        FWHM_y = 2*np.sqrt(2*np.log(2))*y_params[2]
        mu_x = x_params[1]
        mu_y = y_params[1]
       
        fitness = (Amplitude_x*Amplitude_y)/(FWHM_x*FWHM_y)
    except:
        print("##############\nAn exception occurred while calculating gaussian fitness!\n##############")
        fitness = 0
    if return_all:
        return fitness, I_total, I_max, FWHM_x, FWHM_y, mu_x, mu_y, Amplitude_x, Amplitude_y
    return fitness

# Sum of squares fitness function
def sum_of_squares(setting):
    #send setting and retrieve image
    try:
        send_setting(setting)
        img = get_image()
    except:
        return 0
    
    fitness = np.sum(img**2)
    return fitness
