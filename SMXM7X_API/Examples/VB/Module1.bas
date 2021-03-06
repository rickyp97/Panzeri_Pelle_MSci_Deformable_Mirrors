Attribute VB_Name = "Module1"

Private Type TCxScreenParams
     StartX As Long
     StartY As Long
     Width As Long
     Height As Long
     Decimation As Long
     ColorDeep As Long
     MirrorV As Boolean
     MirrorH As Boolean
End Type

Private Type TCameraInfo
    SensorType As Long
    MaxWidth   As Long
    MaxHeight  As Long
    DeviceName(0 To 63) As Byte
End Type

Private Type TCameraInfoEx
    HWModelID As Integer
    HWVersion As Integer
    HWSerial  As Long
    Reserved(0 To 4) As Byte
End Type

Private Type TRgbPix
    B As Byte
    G As Byte
    R As Byte
End Type


    Private Declare Function VbOpenDevice Lib "SMXM7X.DLL" Alias "CxOpenDevice" (ByVal DeviceID As Long) As Long
    Private Declare Function VbCloseDevice Lib "SMXM7X.DLL" Alias "CxCloseDevice" (ByVal DeviceHandle As Long) As Boolean
                                              
    Private Declare Function VbGetCameraInfo Lib "SMXM7X.DLL" Alias "CxGetCameraInfo" (ByVal DeviceHandle As Long, ByRef CameraInfo As TCameraInfo) As Boolean
    Private Declare Function VbGetCameraInfoEx Lib "SMXM7X.DLL" Alias "CxGetCameraInfoEx" (ByVal DeviceHandle As Long, ByRef CameraInfoEx As TCameraInfoEx) As Boolean

    Private Declare Function VbGetStreamMode Lib "SMXM7X.DLL" Alias "CxGetStreamMode" (ByVal DeviceHandle As Long, ByRef StreamMode As Byte) As Boolean
    Private Declare Function VbSetStreamMode Lib "SMXM7X.DLL" Alias "CxSetStreamMode" (ByVal DeviceHandle As Long, ByVal StreamMode As Byte) As Boolean

    Private Declare Function VbGetScreenParams Lib "SMXM7X.DLL" Alias "CxGetScreenParams" (ByVal DeviceHandle As Long, ByRef Params As TCxScreenParams) As Boolean
    Private Declare Function VbSetScreenParams Lib "SMXM7X.DLL" Alias "CxSetScreenParams" (ByVal DeviceHandle As Long, ByRef Params As TCxScreenParams) As Boolean
    Private Declare Function VbActivateScreenParams Lib "SMXM7X.DLL" Alias "CxActivateScreenParams" (ByVal DeviceHandle As Long) As Boolean

    Private Declare Function VbGetFrequency Lib "SMXM7X.DLL" Alias "CxGetFrequency" (ByVal DeviceHandle As Long, ByRef Frequency As Byte) As Boolean
    Private Declare Function VbSetFrequency Lib "SMXM7X.DLL" Alias "CxSetFrequency" (ByVal DeviceHandle As Long, ByVal Frequency As Byte) As Boolean

    Private Declare Function VbGetExposureMinMax Lib "SMXM7X.DLL" Alias "CxGetExposureMinMax" (ByVal DeviceHandle As Long, ByRef MinExposure As Long, ByRef MaxExposure As Long) As Boolean
    Private Declare Function VbGetExposure Lib "SMXM7X.DLL" Alias "CxGetExposure" (ByVal DeviceHandle As Long, ByRef Exposure As Long) As Boolean
    Private Declare Function VbSetExposure Lib "SMXM7X.DLL" Alias "CxSetExposure" (ByVal DeviceHandle As Long, ByVal Exposure As Long) As Boolean

    Private Declare Function VbGetExposureMinMaxMs Lib "SMXM7X.DLL" Alias "CxGetExposureMinMaxMs" (ByVal DeviceHandle As Long, ByRef MinExposure, MaxExposure As Single) As Boolean
    Private Declare Function VbGetExposureMs Lib "SMXM7X.DLL" Alias "CxGetExposureMs" (ByVal DeviceHandle As Long, ByRef ExposureMs As Single) As Boolean
    Private Declare Function VbSetExposureMs Lib "SMXM7X.DLL" Alias "CxSetExposureMs" (ByVal DeviceHandle As Long, ByVal ExposureMs As Single, ByRef ExposureSet As Single) As Boolean

    Private Declare Function VbGetGain Lib "SMXM7X.DLL" Alias "CxGetGain" (ByVal DeviceHandle As Long, ByRef Main As Long, ByRef R As Long, ByRef G As Long, ByRef B As Long) As Boolean
    Private Declare Function VbSetGain Lib "SMXM7X.DLL" Alias "CxSetGain" (ByVal DeviceHandle As Long, ByVal Main As Long, ByVal R As Long, ByVal G As Long, ByVal B As Long) As Boolean
    Private Declare Function VbSetAllGain Lib "SMXM7X.DLL" Alias "CxSetAllGain" (ByVal DeviceHandle As Long, ByVal All As Long, ByVal R As Long) As Boolean

    Private Declare Function VbGrabVideoFrame Lib "SMXM7X.DLL" Alias "CxGrabVideoFrame" (ByVal DeviceHandle As Long, ByVal BufferPtr As Long, ByVal BufSize As Long) As Boolean
    Private Declare Function VbGetFramePtr Lib "SMXM7X.DLL" Alias "CxGetFramePtr" (ByVal DeviceHandle As Long) As Long

    Private Declare Function VbSetBrightnessContrastGamma Lib "SMXM7X.DLL" Alias "CxSetBrightnessContrastGamma" (ByVal DeviceHandle As Long, ByVal B As Long, ByVal C As Long, ByVal G As Long) As Boolean
    Private Declare Function VbSetConvertionTab Lib "SMXM7X.DLL" Alias "CxSetConvertionTab" (ByVal DeviceHandle As Long, ByVal Buf1024Ptr As Long) As Boolean
    Private Declare Function VbGetConvertionTab Lib "SMXM7X.DLL" Alias "CxGetConvertionTab" (ByVal DeviceHandle As Long, ByVal Buf1024Ptr As Long) As Boolean
    Private Declare Function VbSetDefaultConvertionTab Lib "SMXM7X.DLL" Alias "CxSetDefaultConvertionTab" (ByVal DeviceHandle As Long) As Boolean

    Private Declare Function VbStartVideo Lib "SMXM7X.DLL" Alias "CxStartVideo" (ByVal WindowHandle As Long, ByVal DeviceID As Long) As Boolean
    Private Declare Function VbStopVideo Lib "SMXM7X.DLL" Alias "CxStopVideo" (ByVal DeviceID As Long) As Boolean
    Private Declare Function VbGetFrameCounter Lib "SMXM7X.DLL" Alias "CxGetFrameCounter" (ByVal DeviceID As Long, ByRef FrameCounter As Long) As Boolean

    Private Declare Function VbSetBayerAlg Lib "SMXM7X.DLL" Alias "CxSetBayerAlg" (ByVal BayerAlg As Long) As Boolean
    Private Declare Function VbBayerToRgb Lib "SMXM7X.DLL" Alias "CxBayerToRgb" (ByVal InBufPtr As Long, ByVal ScW As Long, ByVal ScH As Long, ByVal AlgId As Long, ByVal FramePtr As Long) As Long
    
    Private Declare Function VbGetCustomData Lib "SMXM7X.DLL" Alias "CxGetCustomData" (ByVal H As Long, Command As Long, ByRef OutData As Long) As Boolean

    Private Declare Function VbWriteSensorReg Lib "SMXM7X.DLL" Alias "CxWriteSensorReg" (ByVal H As Long, ByVal RegNo As Long, ByVal Value As Long) As Boolean
    Private Declare Function VbReadSensorReg Lib "SMXM7X.DLL" Alias "CxReadSensorReg" (ByVal H As Long, ByVal RegNo As Long, ByRef Value As Long) As Boolean

    Private Declare Function VbSetControlReg Lib "SMXM7X.DLL" Alias "CxSetControlReg" (ByVal H As Long, ByVal Value As Byte, ByVal Mask As Byte, ByVal ControlRegNo As Byte) As Boolean
    Private Declare Function VbGetControlReg Lib "SMXM7X.DLL" Alias "CxGetControlReg" (ByVal H As Long, ByRef Value As Byte, ByVal ControlRegNo As Byte) As Boolean


Public Sub StartVideo()
    Dim DeviceH As Long
    Dim Params As TCxScreenParams
    
    DeviceH = VbOpenDevice(0)
    If DeviceH <> -1 Then
        Form1.Picture1.Visible = True
        VbGetScreenParams DeviceH, Params
        Params.Width = 320
        Params.Height = 200
        VbSetScreenParams DeviceH, Params
        VbSetGain DeviceH, 0, 0, 0, 0
        VbCloseDevice DeviceH
        VbSetBayerAlg 2
        VbStartVideo Form1.Picture1.hWnd, 0
    End If
End Sub


Public Sub StopVideo()
    VbStopVideo 0
    Form1.Picture1.Visible = False
End Sub

