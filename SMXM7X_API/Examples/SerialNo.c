/*
    Output serial Number of camera
*/
#include <windows.h>
#include <process.h>

#include "..\SMXM7X.h"


BOOL CxGetSerialNo(HANDLE H, DWORD *SerialNo ) {
    TCameraInfoEx CameraInfoEx;

    if ( CxGetCameraInfoEx( H, &CameraInfoEx) ) {
        *SerialNo = CameraInfoEx.HWSerial;
        return TRUE;
    } else {
        return FALSE;
    }
}


int main(void) {
    HANDLE H = CxOpenDevice(0); // open 1st camera
    DWORD SerialNo = 0;

    if (H != INVALID_HANDLE_VALUE ) {
        if (! CxGetSerialNo(H, &SerialNo) ) {
            printf( "Error : serial no not found !\n" );
        } else {
            printf( "SerialNo:%u\n", SerialNo);
        }
        CxCloseDevice( H );
    } else {
        printf( "Error open Camera #0\n" );
    }
}    
