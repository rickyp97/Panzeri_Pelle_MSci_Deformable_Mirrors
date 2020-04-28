"""
Python wrapper for controlling a SMXM7X camera through its API.
Creates a Cam class, that contains a CSumixCam c_cam object, as defined in the API.
To add additional functionality (defined in the API file SMXM7X.h), you need to modify both the cSMXM7X.pyd file, and this file.
"""
from libcpp cimport bool
from cSMXM7X cimport *                         #the cSMXM7X.pyd file must be in the same directory as this file
import numpy as np
from cpython cimport array
from PIL import Image
 
cdef class Cam:
    cdef CSumixCam c_cam
    cdef void* handle
    cdef TFrameParams frameParams
    cdef TCameraInfo cameraInfo
    
    def __cinit__(self):                        #class constructor
        self.c_cam = CSumixCam()
        #print("Loading DLL...")
        self.c_cam.Initialize()
    
    def OpenDevice(self, DeviceId):             #initialize a device (usually camera is device 0), call after constructor
        #print("Opening device...")
        self.handle = self.c_cam.CxOpenDevice(DeviceId)
        
    def CloseDevice(self):                      #closes device
        #print("Closing device...")
        self.c_cam.CxCloseDevice(self.handle)
        
    def GetFrameParams(self):                   #returns a series of parameters relative to camera frame, resolution etc.
        #print("Retrieving frame params...")
        self.c_cam.CxGetScreenParams(self.handle, &self.frameParams)
        return(self.frameParams)

    def GetCameraInfo(self):                    #returns info on the camera
        #print("Retrieving camera info...")
        self.c_cam.CxGetCameraInfo(self.handle, &self.cameraInfo)
        return(self.cameraInfo)
        
    def SetExposure(self, exposure):            #set camera exposure time, in milliseconds
        #print("Setting exposure...")
        cdef float ExpMs
        self.c_cam.CxSetExposureMs(self.handle, exposure, &ExpMs)
        return ExpMs                            #returns the new exposure time. Note this may be slightly different than the requested exposure time
    
    def SetAllGain(self, gain):                 #set sensor gain
        #print("Setting gain on all channels...")
        return self.c_cam.CxSetAllGain(self.handle, gain)
    
    def SetStreamMode(self, mode):
        #print("Setting stream mode...")
        return self.c_cam.CxSetStreamMode(self.handle, mode)
        
    def SetFrequency(self,freq):
        return self.c_cam.CxSetFrequency(self.handle,freq)

    #gets a frame from the camera, code attempts 20 times to take picture with 99.5% of good pixels
    def GetSnapshot(self, timeout = 10, ExtTrgEnabled = False, ExtTrgPositive = False, NoWaitEvent = True):
        #print("Setting up data...")
        self.GetFrameParams()
        cdef int bufsize = self.frameParams.Width * self.frameParams.Height
        cdef unsigned char[::1] buff = np.empty(bufsize, dtype=np.uint8)
        cdef unsigned char[::1] RGBbuff = np.empty(3*bufsize, dtype=np.uint8)
        cdef int i
        snap = np.zeros(3*bufsize, dtype = np.uint8)
        
        #print("Getting snaphot...")
        cdef unsigned long retsize
        snap_exit = True
        attempts = 0
        
        print("Attempting to take valid snap...")
        while(snap_exit):
            if not self.c_cam.CxGetSnapshot(self.handle, timeout, ExtTrgEnabled, ExtTrgPositive, NoWaitEvent, &buff[0], bufsize, &retsize):
                print("Error while taking snapshot! Check camera connection!")
            if retsize == 0:
                print("Zero output from snapshot! Maybe a timeout occourred?")
            
            percent = (<double> retsize)/(<double> bufsize)* 100
            if percent > 99.5:
                snap_exit = False
                
            if attempts == 20:
                #print("snapshot still invalid after many attempts! aborting...")
                snap_exit = False
            attempts += 1
            
        #print("Snapped ",retsize, " bytes")
        #print("Converting bayer to RGB...")
        self.c_cam.CxBayerToRgb(&buff[0], self.frameParams.Width, self.frameParams.Height, 2, <TRgbPix *> &RGBbuff[0]);
        #print("Transferring data from buffer...")
        for i in range(3*bufsize):
            snap[i] = RGBbuff[i]
            
        #free(buff)
        #free(RGBbuff)
        return snap.reshape(self.frameParams.Height, self.frameParams.Width, 3)
    
    #save a frame at the given file location
    def SaveSnapshot(self, folder, filename):
        #print("snap requested..")
        #print("snapshot taken, score: %f" % score)
        im = Image.fromarray(self.GetSnapshot())
        #print("snap converted to Image object")
        im.save(folder + filename)
        #print("Image saved")
        return
        