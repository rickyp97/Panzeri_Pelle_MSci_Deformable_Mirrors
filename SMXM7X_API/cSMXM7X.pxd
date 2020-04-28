from libcpp cimport bool

# import from the API
cdef extern from "SMXM7X.h":
    #import SMXM7X_CameraStatus enum
    ctypedef enum SMXM7X_CameraStatus:
        CAMERA_STOP = 0, CAMERA_START = 1
        
    #import SMXM7X_Frequency enum    
    ctypedef enum SMXM7X_Frequency:
        FREQ_40 = 0,FREQ_24,FREQ_20,FREQ_16,FREQ_13, FREQ_12, FREQ_10, FREQ_8, FREQ_6, FREQ_32, FREQ_48
    
    #import TFrameParams struct
    ctypedef struct TFrameParams:
        int StartX,StartY;
        int Width,Height;
        int Decimation;
        int ColorDeep;
        bool MirrorV;
        bool MirrorH;
        pass
    
    #import TCameraInfo
    ctypedef struct TCameraInfo:
        int SensorType;
        int MaxWidth;
        int MaxHeight;
        char DeviceName[64];
        pass
   
    #import TRgbPix
    ctypedef struct TRgbPix:
        unsigned char b;
        unsigned char g;
        unsigned char r;
        pass
    
    #import CSumixCam class
    cdef cppclass CSumixCam:
        CSumixCam() except +
        void* CxOpenDevice(int DeviceId)
        bool CxCloseDevice(void* DeviceHandle)
        bool Initialize()
        bool CxGetScreenParams(void* DeviceHandle, TFrameParams *Params)
        bool CxGetCameraInfo(void* DeviceHandle, TCameraInfo *Info)
        bool CxGetSnapshot(void* DeviceHandle, int Timeout, bool ExtTrgEnabled, bool ExtTrgPositive, bool NoWaitEvent, void *Buffer, int BufSize, unsigned long *RetLen)
        bool CxSetStreamMode(void* DeviceHandle, char StreamMode)
        bool CxSetAllGain(void* DeviceHandle, int All)
        bool CxSetExposureMs(void* DeviceHandle, float ExposureMs, float *ExposureSet)
        bool CxSetFrequency(void* DeviceHandle, unsigned char FreqValue)
        TRgbPix CxBayerToRgb(void *BayerMatrix, int ScW, int ScH, int AlgId, TRgbPix *Frame);

        pass