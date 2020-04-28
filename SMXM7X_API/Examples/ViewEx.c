#include <windows.h>
#include <process.h>

#include "..\SMXM7X.h"

// timer ID & interval
#define IDT_TIMERFPS 1089
//#define TIMER_INTERVAL 3 /* sec */

// resolution
#define ID_160x120      197199
#define ID_320x240      197200
#define ID_400x400      197201
#define ID_640x480      197202
#define ID_800x600      197203
#define ID_1024x768     197204
#define ID_1280x1024    197205

// frequency
#define ID_48MHZ        200048
#define ID_40MHZ        200040
#define ID_24MHZ        200024
#define ID_20MHZ        200020
#define ID_16MHZ        200016
#define ID_13MHZ        200013
#define ID_12MHZ        200012
#define ID_10MHZ        200010
#define ID_08MHZ        200008
#define ID_06MHZ        200006

#define ID_0            200000
#define ID_1            200001



#define  IOCTL_GetFrameEx                 CTL_CODE( FILE_DEVICE_UNKNOWN, 0x080F, METHOD_OUT_DIRECT, FILE_ANY_ACCESS )


enum  {
    SMXM71M_SensorType = 0,
    SMXM71C_SensorType = 1,
    
    SMXM71_Width = 1280,
    SMXM71_Height = 1024,
    SMXM71_SensorWidth = 1280,
    SMXM71_SensorHeight = 1024,

    SMXM72M_SensorType = 0x10,
    SMXM72C_SensorType = 0x11,

    SMXM72_Width = 1600,
    SMXM72_Height = 1200,
    SMXM72_SensorWidth = 1600,
    SMXM72_SensorHeight = 1200,

    SMXM73M_SensorType = 0x20,
    SMXM73C_SensorType = 0x21,

    SMXM73_Width = 2048,
    SMXM73_Height = 1536,
    SMXM73_SensorWidth = 2048,
    SMXM73_SensorHeight = 1536,

    SMXM7X_MaxFrameSizeY = SMXM73_SensorHeight,
    SMXM7X_MaxFrameSizeX = SMXM73_SensorWidth,

    SMXM7X_MaxFrameSize = (SMXM7X_MaxFrameSizeX * SMXM7X_MaxFrameSizeY * 2)
//    SMXM95_MaxSizeX = 2592,
//    SMXM95_MaxSizeY = 1944
};


#pragma pack(push,1)
/// FrameInfo struct ( header of buffer) for call CxGrabVideoFrameEx
typedef struct tagFRAMEINFOEX {
    
    TFrameParams FrameParams;   ///< Frame parameters

    BYTE Is10Bits;              ///< TRUE if video stream used 10 bit per pixel; FALSE - if 8 bit
    BYTE Align4;                ///< for align 4

    LONG StreamStatus;          ///< Stream status

    LONG FrameNo;               ///< Frame number
        
    LONG FrameSize;             ///< FrameSize
    LONG LineBytes;             ///< Length of line in bytes
    LONG FrameSizeX;            ///< Real width of frame
    LONG FrameSizeY;            ///< Real height of frame

    LARGE_INTEGER StartTime;    ///< Start time of frame
    LARGE_INTEGER FinishTime;   ///< Finish time of frame

    LONG Resyncs;               ///< Frame resyncs

    LONG MaskChanges;           ///< Count of mask changes
    BYTE Masks[ SMXM7X_MaxFrameSizeY ]; ///< Masks of external events

/*
Short description of 'Time stamp' feature
-----------------------------------------

bit7 bit6 bit5 - three highest bits of line counter


bit7 - pin1 of the external connector.
bit6 - inverted pin4 of the external connector.
bit5 - Software controlled. Connected to bit 7 of register#3.

Bit6 of Register #3 controls the mode of 'Time stamp' feature. 
0 - Continious mode. Each signal connected directly to corresponding highest bit of line counter
1 - Reset mode. Highest bits of line counter are being reset in the begining of a new line.
In another words, if R3.6=0, each signal connected to correspondent bit in line counter; 
if R3.6=1 each signal is latched in RS trigger, which is resetted in the begining of each line.
*/

/// bit0 - 1 if line valid, 0 - if line no correct
///
} FRAMEINFOEX;


/// size of header when call IOCTL_GetFrameEx, /* 4Kbytes, frame info struct size */
#define FRAMEINFOEX_SIZE                (4*1024) 

/// get pointer to FRAMEINFOEX for buffer from IOCTL_GetFrameEx
#define GET_FRAMEINFOEX(FrameInfoPtr)   ( (FRAMEINFOEX*)(FrameInfoPtr) )

/// get frame buffer to FRAMEINFOEX for buffer from IOCTL_GetFrameEx
#define GET_FRAME_BUFFER(FrameInfoPtr)  ( (BYTE*)(FrameInfoPtr) + FRAMEINFOEX_SIZE )


#pragma pack( pop )

static HANDLE SMX;
static HINSTANCE hinst; 
static HWND hwin;
static char WinClassName[] = "__test__";

static int FPS = 0;

BYTE frame[ SMXM7X_MaxFrameSize + FRAMEINFOEX_SIZE ];

// bitmaininfo for SetDIBToDevice
static struct {
    BITMAPINFOHEADER bmhi; 
    RGBQUAD bmip[256];
} bmi;




BOOL CxGrabVideoFrameEx( HANDLE H, VOID* Buffer, INT BufSize ) {
    BOOL    Result;
    DWORD   RetLen;
    
    Result = DeviceIoControl( H, IOCTL_GetFrameEx, NULL, 0, Buffer, BufSize, &RetLen, NULL );

    if (! Result ) {
        SetLastError( ERROR_READ_FAULT );
    }
    return Result;
}



void error(char *Title) { 
    LPVOID lpMsgBuf;
    if (!FormatMessage( 
        FORMAT_MESSAGE_ALLOCATE_BUFFER | 
        FORMAT_MESSAGE_FROM_SYSTEM | 
        FORMAT_MESSAGE_IGNORE_INSERTS,
        NULL,
        GetLastError(),
        MAKELANGID(LANG_NEUTRAL, SUBLANG_DEFAULT), // Default language
        (LPTSTR) &lpMsgBuf,
        0,
        NULL ))
    {
        // Handle the error.
        return;
    }
    // Display the string.
    MessageBox( NULL, (LPCTSTR)lpMsgBuf, Title, MB_OK | MB_ICONINFORMATION );
    // Free the buffer.
    LocalFree( lpMsgBuf );
}


void AddMenu(HWND hwin) {
    HMENU hmenu = GetSystemMenu(hwin,FALSE);
    AppendMenu( hmenu, MF_SEPARATOR, 0, "");

    AppendMenu( hmenu, MF_STRING | MF_ENABLED, ID_160x120  , "160x120" );
    AppendMenu( hmenu, MF_STRING | MF_ENABLED, ID_320x240  , "320x240" );
    AppendMenu( hmenu, MF_STRING | MF_ENABLED, ID_400x400  , "400x400" );
    AppendMenu( hmenu, MF_STRING | MF_ENABLED, ID_640x480  , "640x480" );
    AppendMenu( hmenu, MF_STRING | MF_ENABLED, ID_800x600  , "800x600" );
    AppendMenu( hmenu, MF_STRING | MF_ENABLED, ID_1024x768 , "1024x768" );
    AppendMenu( hmenu, MF_STRING | MF_ENABLED, ID_1280x1024, "1280x1024" );

    AppendMenu( hmenu, MF_SEPARATOR, 0, "");
    
    AppendMenu( hmenu, MF_STRING | MF_ENABLED, ID_48MHZ  , "48 Mhz" );
    AppendMenu( hmenu, MF_STRING | MF_ENABLED, ID_40MHZ  , "40 Mhz" );
    AppendMenu( hmenu, MF_STRING | MF_ENABLED, ID_24MHZ  , "24 Mhz" );
    AppendMenu( hmenu, MF_STRING | MF_ENABLED, ID_20MHZ  , "20 Mhz" );
    AppendMenu( hmenu, MF_STRING | MF_ENABLED, ID_16MHZ  , "16 Mhz" );
    AppendMenu( hmenu, MF_STRING | MF_ENABLED, ID_13MHZ  , "13.33 Mhz" );
    AppendMenu( hmenu, MF_STRING | MF_ENABLED, ID_12MHZ  , "12 Mhz" );
    AppendMenu( hmenu, MF_STRING | MF_ENABLED, ID_10MHZ  , "10 Mhz" );
    AppendMenu( hmenu, MF_STRING | MF_ENABLED, ID_08MHZ  , " 8 Mhz" );
    AppendMenu( hmenu, MF_STRING | MF_ENABLED, ID_06MHZ  , " 6.66 Mhz" );

//    AppendMenu( hmenu, MF_SEPARATOR, 0, "");

//    AppendMenu( hmenu, MF_STRING | MF_ENABLED, ID_0  , "set Event bit to 0" );
//    AppendMenu( hmenu, MF_STRING | MF_ENABLED, ID_1  , "set Event bit to 1" );
}


static void ThreadProc(void *foo);
static LRESULT CALLBACK WinProc( HWND hwnd, UINT uMsg, WPARAM wParam, LPARAM lParam);
 
int PASCAL WinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance, LPSTR lpszCmdLine, int nCmdShow) { 
    MSG msg;
    BOOL bRet; 
    WNDCLASSEX wcx; 
    int i;
    TFrameParams Params;
    UNREFERENCED_PARAMETER(lpszCmdLine); 


    // Register the window class for the main window. 
    if (!hPrevInstance)  { 
        // Fill in the window class structure with parameters that describe the main window. 
        wcx.cbSize = sizeof(wcx);               // size of structure 
        wcx.style = CS_HREDRAW | CS_VREDRAW;    // redraw if size changes 
        wcx.lpfnWndProc = WinProc;              // points to window procedure 
        wcx.cbClsExtra = 0;                     // no extra class memory 
        wcx.cbWndExtra = 0;                     // no extra window memory 
        wcx.hInstance = NULL; // hinstance;         // handle to instance 
        wcx.hIcon = LoadIcon(NULL,  IDI_WINLOGO /*IDI_APPLICATION*/); // predefined app. icon 
        wcx.hCursor = LoadCursor(NULL,   IDC_ARROW);                    // predefined arrow 
        wcx.hbrBackground = (HBRUSH)GetStockObject(WHITE_BRUSH);                  // white background brush 
        wcx.lpszMenuName =  NULL; //"MainMenu";    // name of menu resource 
        wcx.lpszClassName = WinClassName;  // name of window class 
        wcx.hIconSm = NULL; 

        // Register the window class.  
        if (! RegisterClassEx(&wcx) ) {
            return FALSE;
        }
    }

    SMX = CxOpenDevice(0);
    if (SMX == INVALID_HANDLE_VALUE) {
        error("CxOpenDevice(0)");
        return FALSE;
    }

    if (! CxSetStreamMode(SMX,1)) {
        error("! CxSetStreamMode(SMX,1)");
        return FALSE;
    }

    // Create the main window. 
    hwin = CreateWindowEx( 
        0,                      // no extended styles           
        WinClassName,           // class name                   
        "\? fps",           // window name                  
        //WS_OVERLAPPEDWINDOW,    // overlapped window            
        WS_BORDER | WS_CAPTION | WS_SYSMENU,
        CW_USEDEFAULT,          // default horizontal position  
        CW_USEDEFAULT,          // default vertical position    
        CW_USEDEFAULT,          // default width                
        CW_USEDEFAULT,          // default height               
        (HWND) NULL,            // no parent or owner window    
        (HMENU) NULL,           // class menu used              
        NULL,                   // instance handle              
        NULL);                  // no window creation data      
 
    if (!hwin)  {
        return FALSE;
    }
 
    ShowWindow(hwin, nCmdShow); 

    if (! CxGetScreenParams(SMX,&Params) ) {
        error("! CxGetScreenParams(SMX,&Params)");
    }

    if (_beginthread(ThreadProc, 0, NULL ) == -1) {
        error("_beginthread(ThreadProc, 0, NULL )");
//        return FALSE;
    }

    AddMenu(hwin);

    UpdateWindow(hwin); 
/*
    SetTimer(
        hwin,               // handle to main window 
        IDT_TIMERFPS,       // timer identifier 
        TIMER_INTERVAL * 1000 ,              // 3 second interval 
        (TIMERPROC) NULL
    );
*/    
    hinst = hInstance;  // save instance handle 

    // fill bitmapinfo structure
    for (i = 0; i < 256; i++) {
        bmi.bmip[i].rgbBlue = bmi.bmip[i].rgbGreen = bmi.bmip[i].rgbRed = i;
        bmi.bmip[i].rgbReserved = 0;
    }

    bmi.bmhi.biSize         = sizeof(bmi.bmhi);
    bmi.bmhi.biPlanes       = 1;
    bmi.bmhi.biCompression  = BI_RGB;
    bmi.bmhi.biXPelsPerMeter= 23622;
    bmi.bmhi.biYPelsPerMeter= 23622;
 
    // Start the message loop. 
    while( (bRet = GetMessage( &msg, NULL, 0, 0 )) != 0)
    { 
        if (bRet == -1)
        {
            // handle the error and possibly exit
        }
        else
        {
            TranslateMessage(&msg); 
            DispatchMessage(&msg); 
        }
    }

//    KillTimer(hwin, IDT_TIMERFPS);
    hwin = INVALID_HANDLE_VALUE;

    if (! CxSetStreamMode(SMX,0) ) {
        error("!CxSetStreamMode(SMX,0)");
    }

    CxCloseDevice(SMX);

    // Return the exit code to the system. 
    return msg.wParam; 
} 


static int frameCount = 0;


static LRESULT CALLBACK WinProc( HWND hwnd, UINT uMsg, WPARAM wParam, LPARAM lParam) {
    static int savedCount = 0;

    switch (uMsg) {
/*
        case WM_CLOSE: 
            MessageBox(NULL,"1","1",MB_OK);
            DestroyWindow(hwnd); 
            return 0; 
*/ 
        case WM_DESTROY:
            PostQuitMessage(0); 
            return 0; 

        case WM_SYSCOMMAND:
        {
            int W = 0, H = 0;
            switch (wParam) { 

                case ID_160x120:
                    W = 160; H = 120;
                    break;
                case ID_320x240:
                    W = 320; H = 240;
                    break;
                case ID_400x400:
                    W = 400; H = 400;
                    break;
                case ID_640x480:
                    W = 640; H = 480;
                    break;
                case ID_800x600:
                    W = 800; H = 600;
                    break;
                case ID_1024x768:
                    W = 1024; H = 768;
                    break;
                case ID_1280x1024:
                    W = 1280; H = 1024;
                    break;

///            0   1   2   3   4    5    6   7  8    9
/// SortFreq: 48, 40, 24, 20, 16, 13.3, 12, 10, 8, 6.6
                case ID_48MHZ: CxSetFrequency(SMX,0); return 0;
                case ID_40MHZ: CxSetFrequency(SMX,1); return 0;
                case ID_24MHZ: CxSetFrequency(SMX,2); return 0;
                case ID_20MHZ: CxSetFrequency(SMX,3); return 0;
                case ID_16MHZ: CxSetFrequency(SMX,4); return 0;
                case ID_13MHZ: CxSetFrequency(SMX,5); return 0;
                case ID_12MHZ: CxSetFrequency(SMX,6); return 0;
                case ID_10MHZ: CxSetFrequency(SMX,7); return 0;
                case ID_08MHZ: CxSetFrequency(SMX,8); return 0;
                case ID_06MHZ: CxSetFrequency(SMX,9); return 0;
                default:
                    break;
            }
            if (W>0 && H>0) {
                TFrameParams Params;
                if (! CxGetScreenParams(SMX,&Params) ) {
                    error("! CxGetScreenParams(SMX,&Params)");
                    PostMessage(hwin,WM_CLOSE,0,0);
                }
                Params.StartX = Params.StartY = 0;
                Params.Width = W;
                Params.Height = H;
                if (! CxSetScreenParams(SMX,&Params) ) {
                    error("! CxSetScreenParams(SMX,&Params)");
                    PostMessage(hwin,WM_CLOSE,0,0);
                }
                return 0;
            } else {
                break;
            }
        }
/*            
        case WM_TIMER: 
            switch (wParam) { 
                // Process the 1-second timer. 
                case IDT_TIMERFPS: 
                {
                    char buf[256];
                    sprintf(buf,"%d fps", (frameCount - savedCount) / TIMER_INTERVAL );
                    SetWindowText(hwin,buf);
                    savedCount = frameCount;
                    return 0; 
                }
            } 
*/
//        default: 
//            return DefWindowProc(hwnd, uMsg, wParam, lParam); 
    
    }
//    return 0;
    return DefWindowProc(hwnd, uMsg, wParam, lParam); 
}


static void ThreadProc(void *foo) {
    static int savedW = 0, savedH = 0;
    char buf[256];

    while (hwin != INVALID_HANDLE_VALUE) {
        int Resyncs = 0;
        int MaskChanges = 0;
        int i, ValidLines;
        FRAMEINFOEX* FrameInfo = (FRAMEINFOEX*)frame;
        HDC hdc;

        if (! CxGrabVideoFrameEx(SMX,frame,sizeof(frame)) ) {
            error("! CxGrabVideoFrameEx(SMX,frame)");
            PostMessage(hwin,WM_CLOSE,0,0);
            continue;
        }
        
//      sprintf(buf,"%dx%d \n", savedW, savedH );
//      OutputDebugString( buf );


        // changed Width or Height
        if ( savedW != FrameInfo->FrameSizeX || savedH != FrameInfo->FrameSizeY ) {
            RECT rViewWin, r;
            
            savedW = FrameInfo->FrameSizeX;
            savedH = FrameInfo->FrameSizeY;
            r.left = r.top = 0;
            r.right = savedW;
            r.bottom = savedH;
            AdjustWindowRect(&r, WS_OVERLAPPEDWINDOW, FALSE);
            GetWindowRect(hwin, &rViewWin);
            MoveWindow(hwin, rViewWin.left, rViewWin.top, (r.right-r.left+1), (r.bottom-r.top+1), TRUE);
        }

        bmi.bmhi.biWidth = savedW;
        bmi.bmhi.biHeight = -savedH;
        bmi.bmhi.biBitCount = 8;
        bmi.bmhi.biSizeImage = savedW * savedH;

        hdc = GetDC( hwin );
        SetDIBitsToDevice( hdc, 0, 0, savedW, savedH, 0, 0, 0, savedH, GET_FRAME_BUFFER(frame), (BITMAPINFO *)&bmi, DIB_RGB_COLORS );
        ReleaseDC( hwin, hdc ); 

        Resyncs += FrameInfo->Resyncs;
        MaskChanges += FrameInfo->MaskChanges;
        ValidLines = 0;
        for ( i = 0; i < FrameInfo->FrameSizeY; ++i ) {
            if (FrameInfo->Masks[i] & 0x01 ) 
                ++ValidLines;
        }
        sprintf(buf,"Resyncs=%d MaskChanges=%d ValidLines=%d Mask=%02Xh", Resyncs, MaskChanges, ValidLines, FrameInfo->Masks[0] );
        SetWindowText(hwin,buf);

        UpdateWindow(hwin);

    }
}
