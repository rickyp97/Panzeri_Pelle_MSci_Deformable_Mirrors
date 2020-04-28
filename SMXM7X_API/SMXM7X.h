#include <stddef.h>
#include <windows.h>


#if !defined(SMXM7X_H)
#define SMXM7X_H


#define SMXM7X_API_VERSION "1.82"


#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000


#define SMXM7X_API      _stdcall

#define MaxFrameSize    (2048*1600)


#if defined(__cplusplus)
extern "C" {
#endif

//
// Status of camera main stream (video)
//
typedef enum {
    CAMERA_STOP = 0,
    CAMERA_START = 1
} SMXM7X_CameraStatus;


typedef enum { 
    FREQ_40 = 0, FREQ_24, FREQ_20, FREQ_16, FREQ_13, FREQ_12, FREQ_10, FREQ_8, FREQ_6, FREQ_32, FREQ_48
} SMXM7X_Frequency;


#pragma pack(push,1)

//
// Frame info :
//
typedef struct _TFrameParams {
     int StartX,StartY; // start position
     int Width,Height;  // of frame
     int Decimation;    // 1,2,4 (,8 for color camera)
     int ColorDeep;     // 8 or 24
     BOOLEAN MirrorV;   // vertical
     BOOLEAN MirrorH;   // horizontal
} TFrameParams, *PFrameParams;


//
// info about camera
//
typedef struct _TCameraInfo {
    int SensorType;
    int MaxWidth;
    int MaxHeight;
    char DeviceName[64];
} TCameraInfo;


//
// extended info about camera
//
typedef struct _TCameraInfoEx {
    unsigned short HWModelID;
    unsigned short HWVersion;
    unsigned long HWSerial;
    unsigned char Reserved[5];
} TCameraInfoEx;


//
// RGB
//
typedef struct _TRgbPix {
   BYTE b;
   BYTE g;
   BYTE r;
} TRgbPix;

#pragma pack(pop)


HANDLE SMXM7X_API CxOpenDevice(int DeviceId);
BOOL SMXM7X_API CxCloseDevice(HANDLE DeviceHandle);

BOOL SMXM7X_API CxGetCameraInfo  (HANDLE DeviceHandle, TCameraInfo   *CameraInfo );
BOOL SMXM7X_API CxGetCameraInfoEx(HANDLE DeviceHandle, TCameraInfoEx *CameraInfoEx);

BOOL SMXM7X_API CxGetStreamMode(HANDLE DeviceHandle, BYTE *StreamMode);
BOOL SMXM7X_API CxSetStreamMode(HANDLE DeviceHandle, BYTE  StreamMode);

BOOL SMXM7X_API CxGetScreenParams(HANDLE DeviceHandle, TFrameParams *Params);
BOOL SMXM7X_API CxSetScreenParams(HANDLE DeviceHandle, TFrameParams *Params);
BOOL SMXM7X_API CxActivateScreenParams(HANDLE DeviceHandle);

BOOL SMXM7X_API CxGetFrequency(HANDLE DeviceHandle,BYTE *Frequency);
BOOL SMXM7X_API CxSetFrequency(HANDLE DeviceHandle,BYTE  Frequency);

BOOL SMXM7X_API CxGetExposureMinMax(HANDLE DeviceHandle,int *MinExposure,int *MaxExposure);
BOOL SMXM7X_API CxGetExposure(HANDLE DeviceHandle,int *Exposure);
BOOL SMXM7X_API CxSetExposure(HANDLE DeviceHandle,int  Exposure);

BOOL SMXM7X_API CxGetExposureMinMaxMs(HANDLE DeviceHandle,float *MinExposure,float *MaxExposure);
BOOL SMXM7X_API CxGetExposureMs(HANDLE DeviceHandle,float *ExposureMs);
BOOL SMXM7X_API CxSetExposureMs(HANDLE DeviceHandle,float ExposureMs,float *ExposureSet);

BOOL SMXM7X_API CxGetGain(HANDLE DeviceHandle,int *G1, int *R, int *G2, int *B);
BOOL SMXM7X_API CxSetGain(HANDLE DeviceHandle,int  G1, int  R, int  G2, int  B);
BOOL SMXM7X_API CxSetAllGain(HANDLE DeviceHandle,int  All);

BOOL  SMXM7X_API CxGrabVideoFrame(HANDLE DeviceHandle,void *Buffer,int BufSize);
PVOID SMXM7X_API CxGetFramePtr(HANDLE DeviceHandle);

BOOL SMXM7X_API CxSetBrightnessContrastGamma(HANDLE DeviceHandle,int B,int C,int G);
BOOL SMXM7X_API CxSetConvertionTab(HANDLE DeviceHandle, BYTE *Buf1024);
BOOL SMXM7X_API CxGetConvertionTab(HANDLE DeviceHandle, BYTE *Buf1024);
BOOL SMXM7X_API CxSetDefaultConvertionTab(HANDLE DeviceHandle);

BOOL SMXM7X_API CxSetBayerAlg(int BayerAlg);
TRgbPix* SMXM7X_API CxBayerToRgb(void *BayerMatrix, int ScW, int ScH, int AlgId, TRgbPix *Frame);

BOOL SMXM7X_API CxWriteSensorReg(HANDLE DeviceHandle, DWORD RegNo, DWORD  Value);
BOOL SMXM7X_API CxReadSensorReg (HANDLE DeviceHandle, DWORD RegNo, DWORD *Value);
                                
BOOL SMXM7X_API CxSetControlReg (HANDLE DeviceHandle, BYTE  Value, BYTE Mask, BYTE ControlRegNo);
BOOL SMXM7X_API CxGetControlReg (HANDLE DeviceHandle, BYTE *Value,            BYTE ControlRegNo);

BOOL SMXM7X_API CxGetSnapshot(HANDLE DeviceHandle,int Timeout,BOOL ExtTrgEnabled,BOOL ExtTrgPositive,BOOL NoWaitEvent,void *Buffer,int BufSize,DWORD *RetLen);
BOOL SMXM7X_API CxCancelSnapshot(HANDLE DeviceHandle);

BOOL SMXM7X_API CxSet10BitsOutput(HANDLE DeviceHandle, BOOL  Use10Bits);
BOOL SMXM7X_API CxGet10BitsOutput(HANDLE DeviceHandle, BOOL *Use10Bits);
//
BOOL SMXM7X_API CxGetFrameCounter(HANDLE DeviceHandle, DWORD * FCounter);
//

BOOL SMXM7X_API CxSetHBlank(HANDLE DeviceHandle, DWORD   HBlank);
BOOL SMXM7X_API CxGetHBlank(HANDLE DeviceHandle, DWORD * HBlank);

BOOL SMXM7X_API CxSetVBlank(HANDLE DeviceHandle, DWORD   VBlank);
BOOL SMXM7X_API CxGetVBlank(HANDLE DeviceHandle, DWORD * VBlank);

BOOL SMXM7X_API CxSetFrameRate(HANDLE DeviceHandle, float   FrameRate, int * ResultCode);
BOOL SMXM7X_API CxGetFrameRate(HANDLE DeviceHandle, float * FrameRate);

BOOL SMXM7X_API CxSetDefaultFrameRate(HANDLE DeviceHandle);
BOOL SMXM7X_API CxSetMaxFrameRate(HANDLE DeviceHandle);

BOOL SMXM7X_API CxGetStatistics(HANDLE DeviceHandle, int * Frames, int * BadLines );

#if defined(__cplusplus)
}
#endif



#if defined(__cplusplus) // C++ stuff

typedef HANDLE (SMXM7X_API *CxOpenDevice_t)(int DeviceId);
typedef BOOL   (SMXM7X_API *CxCloseDevice_t)(HANDLE DeviceHandle);

typedef BOOL   (SMXM7X_API *CxGetCameraInfo_t)(HANDLE DeviceHandle, TCameraInfo   *CameraInfo );
typedef BOOL   (SMXM7X_API *CxGetCameraInfoEx_t)(HANDLE DeviceHandle, TCameraInfoEx *CameraInfoEx);

typedef BOOL   (SMXM7X_API *CxGetStreamMode_t)(HANDLE DeviceHandle, BYTE *StreamMode);
typedef BOOL   (SMXM7X_API *CxSetStreamMode_t)(HANDLE DeviceHandle, BYTE  StreamMode);

typedef BOOL   (SMXM7X_API *CxGetScreenParams_t)(HANDLE DeviceHandle, TFrameParams *Params);
typedef BOOL   (SMXM7X_API *CxSetScreenParams_t)(HANDLE DeviceHandle, TFrameParams *Params);
typedef BOOL   (SMXM7X_API *CxActivateScreenParams_t)(HANDLE DeviceHandle);

typedef BOOL   (SMXM7X_API *CxGetFrequency_t)(HANDLE DeviceHandle,BYTE *Frequency);
typedef BOOL   (SMXM7X_API *CxSetFrequency_t)(HANDLE DeviceHandle,BYTE  Frequency);

typedef BOOL   (SMXM7X_API *CxGetExposureMinMax_t)(HANDLE DeviceHandle,int *MinExposure,int *MaxExposure);
typedef BOOL   (SMXM7X_API *CxGetExposure_t)(HANDLE DeviceHandle,int *Exposure);
typedef BOOL   (SMXM7X_API *CxSetExposure_t)(HANDLE DeviceHandle,int  Exposure);

typedef BOOL   (SMXM7X_API *CxGetExposureMinMaxMs_t)(HANDLE DeviceHandle,float *MinExposure,float *MaxExposure);
typedef BOOL   (SMXM7X_API *CxGetExposureMs_t)(HANDLE DeviceHandle,float *ExposureMs);
typedef BOOL   (SMXM7X_API *CxSetExposureMs_t)(HANDLE DeviceHandle,float ExposureMs,float *ExposureSet);

typedef BOOL   (SMXM7X_API *CxGetGain_t)(HANDLE DeviceHandle,int *G1,int *R,int *G2,int *B);
typedef BOOL   (SMXM7X_API *CxSetGain_t)(HANDLE DeviceHandle,int  G1,int  R,int  G2,int  B);
typedef BOOL   (SMXM7X_API *CxSetAllGain_t)(HANDLE DeviceHandle,int All);

typedef BOOL   (SMXM7X_API *CxGrabVideoFrame_t)(HANDLE DeviceHandle,void *Buffer,int BufSize);
typedef PVOID  (SMXM7X_API *CxGetFramePtr_t)(HANDLE DeviceHandle);

typedef BOOL   (SMXM7X_API *CxSetBrightnessContrastGamma_t)(HANDLE DeviceHandle,int B,int C,int G);
typedef BOOL   (SMXM7X_API *CxSetConvertionTab_t)(HANDLE DeviceHandle,BYTE *Buf1024);
typedef BOOL   (SMXM7X_API *CxGetConvertionTab_t)(HANDLE DeviceHandle,BYTE *Buf1024);
typedef BOOL   (SMXM7X_API *CxSetDefaultConvertionTab_t)(HANDLE DeviceHandle);

typedef BOOL     (SMXM7X_API *CxSetBayerAlg_t)(int BayerAlg);
typedef TRgbPix* (SMXM7X_API *CxBayerToRgb_t)(void *BayerMatrix, int ScW, int ScH, int AlgId, TRgbPix *Frame);

typedef BOOL	 (SMXM7X_API *CxWriteSensorReg_t)(HANDLE DeviceHandle, DWORD RegNo, DWORD  Value);                             
typedef BOOL	 (SMXM7X_API *CxReadSensorReg_t) (HANDLE DeviceHandle, DWORD RegNo, DWORD *Value);                             
                                                                                                       
typedef BOOL	 (SMXM7X_API *CxSetControlReg_t) (HANDLE DeviceHandle, BYTE  Value, BYTE Mask, BYTE ControlRegNo);
typedef BOOL	 (SMXM7X_API *CxGetControlReg_t) (HANDLE DeviceHandle, BYTE *Value,            BYTE ControlRegNo);

typedef BOOL     (SMXM7X_API *CxGetSnapshot_t)(HANDLE DeviceHandle,int Timeout,BOOL ExtTrgEnabled,BOOL ExtTrgPositive,BOOL NoWaitEvent,void *Buffer,int BufSize,DWORD *RetLen);
typedef BOOL     (SMXM7X_API *CxCancelSnapshot_t)(HANDLE DeviceHandle);

typedef BOOL     (SMXM7X_API *CxSet10BitsOutput_t)(HANDLE DeviceHandle, BOOL  Use10Bits);
typedef BOOL     (SMXM7X_API *CxGet10BitsOutput_t)(HANDLE DeviceHandle, BOOL *Use10Bits);
//
typedef BOOL     (SMXM7X_API *CxGetFrameCounter_t)(HANDLE DeviceHandle,int *FCounter);
//

typedef BOOL     (SMXM7X_API *CxSetHBlank_t)(HANDLE DeviceHandle, DWORD   HBlank);
typedef BOOL     (SMXM7X_API *CxGetHBlank_t)(HANDLE DeviceHandle, DWORD * HBlank);

typedef BOOL     (SMXM7X_API *CxSetVBlank_t)(HANDLE DeviceHandle, DWORD   VBlank);
typedef BOOL     (SMXM7X_API *CxGetVBlank_t)(HANDLE DeviceHandle, DWORD * VBlank);

typedef BOOL     (SMXM7X_API *CxSetFrameRate_t)(HANDLE DeviceHandle, float   FrameRate, int * ResultCode);
typedef BOOL     (SMXM7X_API *CxGetFrameRate_t)(HANDLE DeviceHandle, float * FrameRate);

typedef BOOL     (SMXM7X_API *CxSetDefaultFrameRate_t)(HANDLE DeviceHandle);
typedef BOOL     (SMXM7X_API *CxSetMaxFrameRate_t)(HANDLE DeviceHandle);


typedef BOOL 	 (SMXM7X_API *CxGetStatistics_t)(HANDLE DeviceHandle, int * Frames, int * BadLines );

class CSumixCam {
    
public:
        
    HINSTANCE m_scamlib;

    CSumixCam() {
        ResetFunctions();
//      Initialize();
    }

    virtual ~CSumixCam() {
        Shutdown();
    };

    CxOpenDevice_t                  CxOpenDevice;
    CxCloseDevice_t                 CxCloseDevice;
                                                               
    CxGetCameraInfo_t               CxGetCameraInfo;
    CxGetCameraInfoEx_t             CxGetCameraInfoEx;
                                                               
    CxGetStreamMode_t               CxGetStreamMode;
    CxSetStreamMode_t               CxSetStreamMode;
                                                               
    CxGetScreenParams_t             CxGetScreenParams;
    CxSetScreenParams_t             CxSetScreenParams;
    CxActivateScreenParams_t        CxActivateScreenParams;
                                                               
    CxGetFrequency_t                CxGetFrequency;
    CxSetFrequency_t                CxSetFrequency;
                                                               
    CxGetExposureMinMax_t           CxGetExposureMinMax;
    CxGetExposure_t                 CxGetExposure;
    CxSetExposure_t                 CxSetExposure;
                                                               
    CxGetExposureMinMaxMs_t         CxGetExposureMinMaxMs;
    CxGetExposureMs_t               CxGetExposureMs;
    CxSetExposureMs_t               CxSetExposureMs;
                                                               
    CxSetGain_t                     CxSetGain;
    CxGetGain_t                     CxGetGain;
    CxSetAllGain_t                  CxSetAllGain;
                                                               
    CxGrabVideoFrame_t              CxGrabVideoFrame;
    CxGetFramePtr_t                 CxGetFramePtr;
                                                               
    CxSetBrightnessContrastGamma_t  CxSetBrightnessContrastGamma;
    CxSetConvertionTab_t            CxSetConvertionTab;
    CxGetConvertionTab_t            CxGetConvertionTab;
    CxSetDefaultConvertionTab_t   CxSetDefaultConvertionTab;
                                                               
    CxSetBayerAlg_t                 CxSetBayerAlg;
    CxBayerToRgb_t                  CxBayerToRgb;

    CxWriteSensorReg_t              CxWriteSensorReg; 
    CxReadSensorReg_t               CxReadSensorReg; 
                                                  
    CxSetControlReg_t               CxSetControlReg; 
    CxGetControlReg_t               CxGetControlReg; 

    CxGetSnapshot_t                 CxGetSnapshot;
    CxCancelSnapshot_t				CxCancelSnapshot;
	//
	CxGetFrameCounter_t             CxGetFrameCounter; 
    //

    CxSet10BitsOutput_t				CxSet10BitsOutput;
    CxGet10BitsOutput_t 			CxGet10BitsOutput;

    CxSetHBlank_t					CxSetHBlank;
    CxGetHBlank_t                   CxGetHBlank;
                                               
    CxSetVBlank_t                   CxSetVBlank;
    CxGetVBlank_t                   CxGetVBlank;
                           
    CxSetFrameRate_t				CxSetFrameRate;
    CxGetFrameRate_t                CxGetFrameRate;
                           
    CxSetDefaultFrameRate_t			CxSetDefaultFrameRate;
    CxSetMaxFrameRate_t				CxSetMaxFrameRate;

    CxGetStatistics_t				CxGetStatistics;

    void Shutdown() {
        // unload the library
        if (m_scamlib != NULL) {
            ResetFunctions();
            ::FreeLibrary(m_scamlib);
            m_scamlib = NULL;
        }
    }

    BOOL Initialize() {
        // load the library
        m_scamlib = ::LoadLibrary("SMXM7X.dll");
    
        if (m_scamlib == NULL) {
            // AfxThrowFileException(CFileException::fileNotFound, -1, "SMXM7X.dll");
            return FALSE;
        };

        // init the functions as pointers from the dll

        CxOpenDevice = (CxOpenDevice_t)::GetProcAddress( m_scamlib, "CxOpenDevice" );
        CxCloseDevice = (CxCloseDevice_t)::GetProcAddress( m_scamlib, "CxCloseDevice" );
                                      
        CxGetCameraInfo = (CxGetCameraInfo_t)::GetProcAddress( m_scamlib, "CxGetCameraInfo" );
        CxGetCameraInfoEx = (CxGetCameraInfoEx_t)::GetProcAddress( m_scamlib, "CxGetCameraInfoEx" );
                                      
        CxGetStreamMode = (CxGetStreamMode_t)::GetProcAddress( m_scamlib, "CxGetStreamMode" );
        CxSetStreamMode = (CxSetStreamMode_t)::GetProcAddress( m_scamlib, "CxSetStreamMode" );
                                      
        CxGetScreenParams = (CxGetScreenParams_t)::GetProcAddress( m_scamlib, "CxGetScreenParams" );
        CxSetScreenParams = (CxSetScreenParams_t)::GetProcAddress( m_scamlib, "CxSetScreenParams" );
        CxActivateScreenParams = (CxActivateScreenParams_t)::GetProcAddress( m_scamlib, "CxActivateScreenParams" );
                                      
        CxGetFrequency = (CxGetFrequency_t)::GetProcAddress( m_scamlib, "CxGetFrequency" );
        CxSetFrequency = (CxSetFrequency_t)::GetProcAddress( m_scamlib, "CxSetFrequency" );
                                      
        CxGetExposureMinMax = (CxGetExposureMinMax_t)::GetProcAddress( m_scamlib, "CxGetExposureMinMax" );
        CxGetExposure = (CxGetExposure_t)::GetProcAddress( m_scamlib, "CxGetExposure" );
        CxSetExposure = (CxSetExposure_t)::GetProcAddress( m_scamlib, "CxSetExposure" );
                                      
        CxGetExposureMinMaxMs = (CxGetExposureMinMaxMs_t)::GetProcAddress( m_scamlib, "CxGetExposureMinMaxMs" );
        CxGetExposureMs = (CxGetExposureMs_t)::GetProcAddress( m_scamlib, "CxGetExposureMs" );
        CxSetExposureMs = (CxSetExposureMs_t)::GetProcAddress( m_scamlib, "CxSetExposureMs" );
                                      
        CxSetGain = (CxSetGain_t)::GetProcAddress( m_scamlib, "CxSetGain" );
        CxGetGain = (CxGetGain_t)::GetProcAddress( m_scamlib, "CxGetGain" );
        CxSetAllGain = (CxSetAllGain_t)::GetProcAddress( m_scamlib, "CxSetAllGain" );
                                      
        CxGrabVideoFrame = (CxGrabVideoFrame_t)::GetProcAddress( m_scamlib, "CxGrabVideoFrame" );
        CxGetFramePtr = (CxGetFramePtr_t)::GetProcAddress( m_scamlib, "CxGetFramePtr" );
                                      
        CxSetBrightnessContrastGamma = (CxSetBrightnessContrastGamma_t)::GetProcAddress( m_scamlib, "CxSetBrightnessContrastGamma" );
        CxSetConvertionTab = (CxSetConvertionTab_t)::GetProcAddress( m_scamlib, "CxSetConvertionTab" );
        CxGetConvertionTab = (CxGetConvertionTab_t)::GetProcAddress( m_scamlib, "CxGetConvertionTab" );
        CxSetDefaultConvertionTab = (CxSetDefaultConvertionTab_t)::GetProcAddress( m_scamlib, "CxSetDefaultConvertionTab" );
                                      
        CxSetBayerAlg = (CxSetBayerAlg_t)::GetProcAddress( m_scamlib, "CxSetBayerAlg" );
        CxBayerToRgb = (CxBayerToRgb_t)::GetProcAddress( m_scamlib, "CxBayerToRgb" );
                     
        CxWriteSensorReg =  (CxWriteSensorReg_t)::GetProcAddress( m_scamlib, "CxWriteSensorReg");
        CxReadSensorReg  =  (CxReadSensorReg_t)::GetProcAddress( m_scamlib, "CxReadSensorReg");
                                                                
        CxSetControlReg  =  (CxSetControlReg_t)::GetProcAddress( m_scamlib, "CxSetControlReg");
        CxGetControlReg  =  (CxGetControlReg_t)::GetProcAddress( m_scamlib, "CxGetControlReg");

        CxGetSnapshot = (CxGetSnapshot_t)::GetProcAddress( m_scamlib, "CxGetSnapshot" );
        CxCancelSnapshot = (CxCancelSnapshot_t)::GetProcAddress( m_scamlib, "CxCancelSnapshot" );

        CxSet10BitsOutput = (CxSet10BitsOutput_t)::GetProcAddress( m_scamlib, "CxSet10BitsOutput" );
        CxGet10BitsOutput = (CxGet10BitsOutput_t)::GetProcAddress( m_scamlib, "CxGet10BitsOutput" );
		//
		CxGetFrameCounter = (CxGetFrameCounter_t)::GetProcAddress( m_scamlib, "CxGetFrameCounter");
		//

		CxSetHBlank = (CxSetHBlank_t)::GetProcAddress( m_scamlib, "CxSetHBlank");
		CxGetHBlank = (CxGetHBlank_t)::GetProcAddress( m_scamlib, "CxGetHBlank");
		                      
		CxSetVBlank = (CxSetHBlank_t)::GetProcAddress( m_scamlib, "CxSetVBlank");
		CxGetVBlank = (CxGetVBlank_t)::GetProcAddress( m_scamlib, "CxGetVBlank");
		                      
		CxSetFrameRate = (CxSetFrameRate_t)::GetProcAddress( m_scamlib, "CxSetFrameRate");
		CxGetFrameRate = (CxGetFrameRate_t)::GetProcAddress( m_scamlib, "CxGetFrameRate");
		                      
		CxSetDefaultFrameRate = (CxSetDefaultFrameRate_t)::GetProcAddress( m_scamlib, "CxSetDefaultFrameRate");
		CxSetMaxFrameRate = (CxSetMaxFrameRate_t)::GetProcAddress( m_scamlib, "CxSetMaxFrameRate");

		CxGetStatistics = (CxGetStatistics_t)::GetProcAddress( m_scamlib, "CxGetStatistics");

        return TRUE;
    }


private:

    void ResetFunctions() {

        CxOpenDevice = NULL;                 
        CxCloseDevice = NULL;                
                                      
        CxGetCameraInfo = NULL;              
        CxGetCameraInfoEx = NULL;            
                                      
        CxGetStreamMode = NULL;              
        CxSetStreamMode = NULL;              
                                      
        CxGetScreenParams = NULL;            
        CxSetScreenParams = NULL;            
        CxActivateScreenParams = NULL;       
                                      
        CxGetFrequency = NULL;               
        CxSetFrequency = NULL;               
                                      
        CxGetExposureMinMax = NULL;          
        CxGetExposure = NULL;                
        CxSetExposure = NULL;                
                                      
        CxGetExposureMinMaxMs = NULL;        
        CxGetExposureMs = NULL;              
        CxSetExposureMs = NULL;              
                                      
        CxSetGain = NULL;                    
        CxGetGain = NULL;                    
        CxSetAllGain = NULL;                    
                                      
        CxGrabVideoFrame = NULL;             
        CxGetFramePtr = NULL;                
                                      
        CxSetBrightnessContrastGamma = NULL;
        CxSetConvertionTab = NULL;
        CxGetConvertionTab = NULL;
        CxSetDefaultConvertionTab = NULL;
                                      
        CxSetBayerAlg = NULL;
        CxBayerToRgb = NULL;

        CxWriteSensorReg = NULL; 
        CxReadSensorReg  = NULL; 
                            
        CxSetControlReg  = NULL; 
        CxGetControlReg  = NULL; 

        CxGetSnapshot = NULL;
        CxCancelSnapshot = NULL;

        CxSet10BitsOutput = NULL;
        CxGet10BitsOutput = NULL;
		//
		CxGetFrameCounter = NULL;
		//
		CxSetHBlank = NULL;
		CxGetHBlank = NULL;
		                       
		CxSetVBlank = NULL;
		CxGetVBlank = NULL;
		                       
		CxSetFrameRate = NULL;
		CxGetFrameRate = NULL;
		                       
		CxSetDefaultFrameRate = NULL;
		CxSetMaxFrameRate = NULL;

		CxGetStatistics = NULL;

    }   
};      
        
#endif // #if defined(__cplusplus)

#endif // #if !defined(SMXM7X_H)
