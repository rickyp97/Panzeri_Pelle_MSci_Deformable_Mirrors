VERSION 5.00
Begin VB.Form Form1 
   Caption         =   "Form1"
   ClientHeight    =   1965
   ClientLeft      =   60
   ClientTop       =   345
   ClientWidth     =   2730
   LinkTopic       =   "Form1"
   ScaleHeight     =   1965
   ScaleWidth      =   2730
   StartUpPosition =   3  'Windows Default
   Begin VB.Label Label3 
      Caption         =   "Label3"
      Height          =   195
      Left            =   195
      TabIndex        =   2
      Top             =   1320
      Width           =   1995
   End
   Begin VB.Label Label2 
      Caption         =   "Label2"
      Height          =   200
      Left            =   200
      TabIndex        =   1
      Top             =   840
      Width           =   2000
   End
   Begin VB.Label Label1 
      Caption         =   "Label1"
      Height          =   200
      Left            =   200
      TabIndex        =   0
      Top             =   360
      Width           =   2000
   End
End
Attribute VB_Name = "Form1"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False

Private Type TCameraInfoEx
    HWModelID As Integer
    HWVersion As Integer
    HWSerial  As Long
    Reserved(0 To 4) As Byte
End Type

    Private Declare Function VbOpenDevice Lib "SMXM7X.DLL" Alias "CxOpenDevice" (ByVal DeviceID As Long) As Long
    Private Declare Function VbCloseDevice Lib "SMXM7X.DLL" Alias "CxCloseDevice" (ByVal DeviceHandle As Long) As Boolean
                                              
    Private Declare Function VbGetCameraInfoEx Lib "SMXM7X.DLL" Alias "CxGetCameraInfoEx" (ByVal DeviceHandle As Long, ByRef CameraInfoEx As TCameraInfoEx) As Boolean


Private Sub Form_Load()
    Dim DeviceH As Long
    Dim CameraInfoEx As TCameraInfoEx
    
    DeviceH = VbOpenDevice(0)
    If DeviceH <> -1 Then
        VbGetCameraInfoEx DeviceH, CameraInfoEx
        Label1.Caption = "HWModelID=" + Trim(Str(CameraInfoEx.HWModelID))
        Label2.Caption = "HWVersion=" + Trim(Str(CameraInfoEx.HWVersion))
        Label3.Caption = "HWSerial=" + Trim(Str(CameraInfoEx.HWSerial))
        VbCloseDevice DeviceH ' Close device
    Else
        Label1.Caption = "Camera 0 NOT FOUND!"
        Label2.Caption = "Camera 0 NOT FOUND!"
        Label3.Caption = "Camera 0 NOT FOUND!"
    End If
    
End Sub

