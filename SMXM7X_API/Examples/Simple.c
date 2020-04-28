#include <windows.h>
#include <process.h>

#include "..\SMXM7X.h"

// timer ID & interval
#define IDT_TIMERFPS 1089
#define TIMER_INTERVAL 3 /* sec */


static HINSTANCE hinst; 
static HWND hwin;
static char WinClassName[] = "__test__";


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

    UpdateWindow(hwin); 
  
    SetTimer(
        hwin,               // handle to main window 
        IDT_TIMERFPS,       // timer identifier 
        TIMER_INTERVAL * 1000 ,              // 3 second interval 
        (TIMERPROC) NULL
    );

    hinst = hInstance;  // save instance handle 

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

    KillTimer(hwin, IDT_TIMERFPS);

    // Return the exit code to the system. 
    return msg.wParam; 
} 



static LRESULT CALLBACK WinProc( HWND hwnd, UINT uMsg, WPARAM wParam, LPARAM lParam) {
    static long savedCount = 0;

    switch (uMsg) {
        
        case WM_CREATE:
        	CxSetBayerAlg(1);
            CxStartVideo( hwnd, 0 );
            break;
        
        case WM_TIMER: 
            switch (wParam) { 
                // Process the N-second timer. 
                case IDT_TIMERFPS: 
                {
                    char buf[256];
                    long frameCount;
                    CxGetFrameCounter(0, &frameCount);

                    sprintf(buf,"%d fps", (frameCount - savedCount) / TIMER_INTERVAL );
                    SetWindowText(hwin,buf);
                    savedCount = frameCount;
                    return 0; 
                }
            }
            break; 
/*
        case WM_CLOSE: 
            MessageBox(NULL,"1","1",MB_OK);
            DestroyWindow(hwnd); 
            return 0; 
*/ 
        case WM_DESTROY:
            CxStopVideo( 0 );
            PostQuitMessage(0); 
            return 0; 
            break; // 
    }
//    return 0;
    return DefWindowProc(hwnd, uMsg, wParam, lParam); 
}
