#include <stdio.h>
#include <iostream>


#include "..\SMXM7X.h"

CSumixCam m_camera;

int main(void){
	std::cout << "Test program for SMXM7X camera\n";
	std::cout << "Opening camera...\n";
	HANDLE Handle;
	float ExposureMin, ExposureMax;
	TFrameParams Params;
	m_camera.Initialize(); // loads dll and initializes the functions
	Handle = m_camera.CxOpenDevice(0); // open the device
	std::cout << "Openekjkljlkljljlkjlkjlkjd device 0\n";
	// now do something useful
	m_camera.CxGetScreenParams(Handle, &Params);
	m_camera.CxGetExposureMinMaxMs(Handle, &ExposureMin, &ExposureMax);
    m_camera.CxCloseDevice(Handle);
	std::cout << "Width: " << Params.Width << ", Height: " << Params.Height;
    m_camera.Shutdown(); // unloads the dll 
}

void displayParams(CSumixCam camera){
	
}

