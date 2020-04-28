/*
    Output serial Number of camera
*/
#include <windows.h>
#include <process.h>

#include "..\SMXM7X.h"



int main(void) {
    HANDLE H = CxOpenDevice(0); // open 1st camera
    float MinMs, MaxMs;

    if (H != INVALID_HANDLE_VALUE ) {
        if (! CxGetExposureMinMaxMs(H, &MinMs, &MaxMs) ) {
            printf( "Error!\n" );
        } else {
            printf( "MinMs=%f MaxMs=%f\n", MinMs, MaxMs );
        }
        CxCloseDevice( H );
    } else {
        printf( "Error open Camera #0\n" );
    }
}    
