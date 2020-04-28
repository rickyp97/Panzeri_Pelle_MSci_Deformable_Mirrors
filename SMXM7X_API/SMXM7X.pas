Unit
	SMXM7X;

Interface

Uses 
    Windows;

Const

    MaxFrameSize = 2048*1600;
//
// Status of camera main stream (video)
//
    CAMERA_STOP 	= 0;
    CAMERA_START 	= 1;
//
// convert Bayer pattern to RGB image method ID
//
    BAYER_LAPLACIAN = 0;// Laplacian 
    BAYER_MONO=1;         // convert to mono 
    BAYER_AVERAGE=2;
    BAYER_NEAREST=3;
    BAYER_BILINEAR=4;

Type

  FrameArray = packed array [0..MaxFrameSize-1] of byte;
  PFrameArray = ^FrameArray;

  TRgbPix    = packed record b,g,r:byte; end;
  TRgbPixArray = packed array [0..MaxFrameSize-1] of TRgbPix;

  TCxScreenParams = packed record
     StartX,StartY : integer;
     Width,Height  : integer;
     Decimation    : integer;
     ColorDeep     : integer;
     MirrorV       : boolean;
     MirrorH       : boolean;
    end;

  TCameraInfo = packed record
    SensorType : integer;
    MaxWidth   : integer;
    MaxHeight  : integer;
    DeviceName : array[0..63] of char;
  end;

  TCameraInfoEx = packed record
    HWModelID : Word;
    HWVersion : Word;
    HWSerial  : DWord;
    Reserved  : Array [0..4] of Byte;
  end;


Function CxOpenDevice(Id : integer) : THandle; stdcall; external 'SMXM7X.dll';
Function CxCloseDevice(H:THandle):boolean; stdcall; external 'SMXM7X.dll';

Function CxGetCameraInfo(H : THandle; var CameraInfo : TCameraInfo):boolean; stdcall; external 'SMXM7X.dll';
Function CxGetCameraInfoEx(H:THandle; var CameraInfoEx:TCameraInfoEx):boolean; stdcall; external 'SMXM7X.dll';

Function CxGetStreamMode(H:THandle; var Mode:byte):boolean; stdcall; external 'SMXM7X.dll';
Function CxSetStreamMode(H:THandle;     Mode:byte):boolean; stdcall; external 'SMXM7X.dll';

Function CxGetScreenParams(H:THandle;   var Params:TCxScreenParams):boolean; stdcall; external 'SMXM7X.dll';
Function CxSetScreenParams(H:THandle; const Params:TCxScreenParams):boolean; stdcall; external 'SMXM7X.dll';
Function CxActivateScreenParams(H:THandle):boolean; stdcall; external 'SMXM7X.dll';

Function CxGetFrequency(H:THandle; var Value:byte):boolean; stdcall; external 'SMXM7X.dll';
Function CxSetFrequency(H:THandle;     Value:byte):boolean; stdcall; external 'SMXM7X.dll';

Function CxGetExposureMinMax(H:THandle; var MinExposure, MaxExposure : integer) : boolean; stdcall; external 'SMXM7X.dll';
Function CxGetExposure(H:THandle; var Exps:integer):boolean; stdcall; external 'SMXM7X.dll';
Function CxSetExposure(H:THandle;     Exps:integer):boolean; stdcall; external 'SMXM7X.dll';

Function CxGetExposureMinMaxMs(H:THandle; var MinExposure, MaxExposure : single) : boolean; stdcall; external 'SMXM7X.dll';
Function CxGetExposureMs(H:THandle; var ExpMs:single):boolean; stdcall; external 'SMXM7X.dll';
Function CxSetExposureMs(H:THandle;     ExpMs:single; var ExpSet:single):boolean; stdcall; external 'SMXM7X.dll';

Function CxGetGain(H:THandle; var G1,R,G2,B :integer):boolean; stdcall; external 'SMXM7X.dll';
Function CxSetGain(H:THandle;     G1,R,G2,B :integer):boolean; stdcall; external 'SMXM7X.dll';
Function CxSetAllGain(H:THandle; Gain : Integer):Boolean;  stdcall; external 'SMXM7X.dll';

Function CxGrabVideoFrame(H:THandle; Buffer:Pointer; BufSize:integer):boolean; stdcall; external 'SMXM7X.dll';
Function CxGetFramePtr(H:THandle):Pointer; stdcall; external 'SMXM7X.dll';

//Function CxMakeConvertionCurve(Br,Ct:integer; Gm:single; var Buf1024):boolean; stdcall; external 'SMXM7X.dll';
Function CxSetBrightnessContrastGamma(H:THandle; B,C,G : integer) : boolean; stdcall;   external 'SMXM7X.dll';
Function CxSetConvertionTab(H:THandle; var Buf1024):boolean; stdcall;                   external 'SMXM7X.dll';
Function CxGetConvertionTab(H:THandle; var Buf1024):boolean; stdcall;                   external 'SMXM7X.dll';
Function CxSetDefaultConvertionTab(H:THandle):boolean; stdcall;                         external 'SMXM7X.dll';

Function CxGetCustomData(H : THandle; Command : Cardinal; var OutData : Cardinal) : boolean; stdcall; external 'SMXM7X.dll';

Function CxSetBayerAlg(BayerAlg : integer) : boolean; stdcall; external 'SMXM7X.dll';
Function CxBayerToRgb(InBuf:pointer; ScW,ScH:integer; AlgId:integer; var Frame:TRgbPixArray):pointer; stdcall; external 'SMXM7X.dll';

Function CxStartVideo(WindowHandle : THandle; DeviceID : integer) : boolean; stdcall; external 'SMXM7X.dll';
Function CxStopVideo(DeviceID : integer) : boolean; stdcall; external 'SMXM7X.dll';
Function CxGetFrameCounter(DeviceID : integer; var FrameCounter : Cardinal) : boolean; stdcall; external 'SMXM7X.dll';

Function CxWhiteBalance(H : THandle) : boolean; stdcall;  external 'SMXM7X.dll';

Function CxGetSnapshot( H:THandle; Timeout:Integer; ExtTrgEnabled:Boolean; ExtTrgPolarity : Boolean; 
    {NoWaitEvent:Boolean;} SnapshotMode:Boolean; Buffer:Pointer; BufSize:Integer; Var RetLen:DWORD ):Boolean; stdcall; external 'SMXM7X.dll';
Function CxCancelSnapshot(H:THandle):Boolean; stdcall; external 'SMXM7X.dll';

Function CxSet10BitsOutput(H : THandle;     Use10Bits : Boolean) : Boolean; stdcall; external 'SMXM7X.dll';
Function CxGet10BitsOutput(H : THandle; Var Use10Bits : Boolean) : Boolean; stdcall; external 'SMXM7X.dll';

Function CxSetHBlank(H : THandle;     HBlank : DWord) : Boolean; stdcall; external 'SMXM7X.dll';
Function CxGetHBlank(H : THandle; Var HBlank : DWord) : Boolean; stdcall; external 'SMXM7X.dll';

Function CxSetVBlank(H : THandle;     VBlank : DWord) : Boolean; stdcall; external 'SMXM7X.dll';
Function CxGetVBlank(H : THandle; Var VBlank : DWord) : Boolean; stdcall; external 'SMXM7X.dll';

Function CxSetFrameRate( H : THandle;     FrameRate:single; var ResultCode : Integer):boolean; stdcall; external 'SMXM7X.dll';
Function CxGetFrameRate( H : THandle; var FrameRate:single):boolean; stdcall; external 'SMXM7X.dll';

Function CxSetDefaultFrameRate( H : THandle ):boolean; stdcall; external 'SMXM7X.dll';
Function CxSetMaxFrameRate( H : THandle ):boolean; stdcall; external 'SMXM7X.dll';

Function CxGetStatistics( H:THandle; var Frames, BadLines : Integer ) : Boolean; stdcall; external 'SMXM7X.dll';

implementation

end.
