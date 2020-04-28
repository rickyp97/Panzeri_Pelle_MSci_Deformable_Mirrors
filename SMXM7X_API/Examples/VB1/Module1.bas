Attribute VB_Name = "Module1"
Private Type BITMAPINFOHEADER
    biSize As Long
    biWidth As Long
    biHeight As Long
    biPlanes As Integer
    biBitCount As Integer
    biCompression As Long
    biSizeImage As Long
    biXPelsPerMeter As Long
    biYPelsPerMeter As Long
    biClrUsed As Long
    biClrImportant As Long
End Type
 
Private Type BGRQuad
    B As Byte
    G As Byte
    R As Byte
    Empty As Byte
End Type
 
Private Type BITMAPINFO
    bmiHeader As BITMAPINFOHEADER
    bmiColors(0 To 255) As Long   ' Enough for 256 colors.
End Type

Private Type BITMAPFILEHEADER
    'bfTypeB As Byte
    'bfTypeM As Byte
    bfSize As Long
    bfReserved As Long
    bfOffBits As Long
End Type


Private Const FILE_ATTRIBUTE_NORMAL As Long = &H80
Private Const GENERIC_WRITE As Long = &H40000000
Private Const OPEN_EXISTING As Long = 3
Private Const CREATE_ALWAYS As Long = 2

Private Declare Function CloseHandle Lib "kernel32.dll" (ByVal hObject As Long) As Long
Private Declare Function CreateFile Lib "kernel32.dll" Alias "CreateFileA" (ByVal lpFileName As String, ByVal dwDesiredAccess As Long, ByVal dwShareMode As Long, ByVal lpSecurityAttributes As Long, ByVal dwCreationDisposition As Long, ByVal dwFlagsAndAttributes As Long, ByVal hTemplateFile As Long) As Long
Private Declare Function WriteFile Lib "kernel32.dll" (ByVal iFileHandle As Long, ByVal lpBuffer As Long, ByVal nNumberOfBytesToWrite As Long, ByRef lpNumberOfBytesWritten As Long, ByVal lpOverlapped As Long) As Long
Private Declare Function GetLastError Lib "kernel32" () As Long



Public Sub SaveAsMonoBitmap(ByVal FileName As String, ByVal lpBuf As Long, ByVal FrameW As Long, ByVal FrameH As Long)
    Dim i As Integer
    Dim BM(0 To 1) As Byte
    Dim BitmapInf As BITMAPINFO
    Dim BitmapFileHdr As BITMAPFILEHEADER
    Dim iFileHandle As Integer
    Dim lBytesWritten As Long
    
    BitmapInf.bmiHeader.biSize = 40
    BitmapInf.bmiHeader.biWidth = FrameW
    BitmapInf.bmiHeader.biHeight = FrameH
    BitmapInf.bmiHeader.biPlanes = 1
    BitmapInf.bmiHeader.biBitCount = 8
    BitmapInf.bmiHeader.biCompression = 0
    BitmapInf.bmiHeader.biClrUsed = 256
    BitmapInf.bmiHeader.biClrImportant = 0
    BitmapInf.bmiHeader.biXPelsPerMeter = 0
    BitmapInf.bmiHeader.biYPelsPerMeter = 0
    BitmapInf.bmiHeader.biSizeImage = FrameW * FrameH
        
    For i = 0 To 255
        BitmapInf.bmiColors(i) = RGB(i, i, i)
    Next i
    
    BM(0) = Asc("B")
    BM(1) = Asc("M")
    BitmapFileHdr.bfReserved = 0
    BitmapFileHdr.bfOffBits = 54 + 1024
    BitmapFileHdr.bfSize = FrameW * FrameH + BitmapFileHdr.bfOffBits
    
    iFileHandle = CreateFile(FileName, GENERIC_WRITE, 0, 0, CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, 0)
    If iFileHandle <> -1 Then
        i = WriteFile(iFileHandle, VarPtr(BM(0)), 2, lBytesWritten, 0)
        i = WriteFile(iFileHandle, VarPtr(BitmapFileHdr), Len(BitmapFileHdr), lBytesWritten, 0)
        i = WriteFile(iFileHandle, VarPtr(BitmapInf), Len(BitmapInf), lBytesWritten, 0)
        i = WriteFile(iFileHandle, lpBuf, BitmapInf.bmiHeader.biSizeImage, lBytesWritten, 0)
        CloseHandle (iFileHandle)
    Else
        Debug.Print "GetLastError=", GetLastError
    End If
    
End Sub


