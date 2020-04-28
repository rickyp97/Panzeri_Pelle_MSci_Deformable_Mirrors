#include <stdio.h>
#include <windows.h>


#include "..\SMXM7X.h"


static void SaveFrame(FILE *fp, BYTE *buf, int H, int LineSize) {
    int i;
    for (i = H-1; i>=0; i--) {
        UCHAR *b = buf + i * LineSize;
        fwrite(b,LineSize,1,fp);
    }
}

BYTE FrameRGB24[1300*1024*3];


int saveBMP(char *fname, void *buf, int W, int H, int bits) {
    FILE *fp = fopen(fname, "wb");
    BITMAPFILEHEADER FileHead;
    BITMAPINFOHEADER InfoHead;
    RGBQUAD Pal[256]; 
    int i;

    if (!fp) {
        perror(fname);
        return FALSE;
    }

    if (bits == 8 ) {
        for(i=0;i<256;i++) {
            Pal[i].rgbBlue = Pal[i].rgbGreen = Pal[i].rgbRed = i;
            Pal[i].rgbReserved = 0;
        }
    }

    memset(&InfoHead,0,sizeof(BITMAPINFOHEADER));
    InfoHead.biSize = sizeof(BITMAPINFOHEADER);
    InfoHead.biBitCount = bits;
    InfoHead.biHeight = H;
    InfoHead.biWidth = W;
    InfoHead.biPlanes = 1;
    InfoHead.biSizeImage = H * W * bits / 8;

    memset(&FileHead,0,sizeof(BITMAPFILEHEADER));
    FileHead.bfType = 0x4D42;
    FileHead.bfOffBits = sizeof(BITMAPFILEHEADER) + sizeof(BITMAPINFOHEADER);
    if (bits == 8) {
        FileHead.bfOffBits += sizeof(Pal);    
    }
    FileHead.bfSize = FileHead.bfOffBits + InfoHead.biSizeImage;

    fwrite(&FileHead,sizeof(BITMAPFILEHEADER),1,fp);
    fwrite(&InfoHead,sizeof(BITMAPINFOHEADER),1,fp);    
    if (bits == 8) {
        fwrite(Pal,sizeof(Pal),1,fp);
        SaveFrame(fp, (UCHAR *)buf, H, W * bits / 8 );
    }
    if (bits == 24) {
    	CxBayerToRgb( buf, W, H, 2 /*bilinear*/, (TRgbPix *)FrameRGB24 );
    	SaveFrame(fp, (UCHAR *)FrameRGB24, H, W * bits / 8 );
    }

    // fwrite(buf,InfoHead.biSizeImage,1,fp);
    fclose(fp);
    return TRUE;
}           



BYTE Frame[1300*1024];


int main(void) {
    CSumixCam m_camera; 
    
    if (! m_camera.Initialize() ) { // loads dll and initializes the functions
        fprintf( stderr, "SMX170.dll NOT FOUND!\n");
        return -1;
    }

    HANDLE H = m_camera.CxOpenDevice(0); // open the device

    if ( H == INVALID_HANDLE_VALUE ) {
        fprintf( stderr, "SMX170 Camera #0 not found!\n");
    	m_camera.Shutdown(); // unloads the dll
        return -1;   	
    }
    //
    // setup Frame Params
    //
    TFrameParams Params;
    memset( &Params, 0, sizeof(Params) );
    Params.Width  = 1280;
    Params.Height = 1024;
    Params.Decimation = 1;
    m_camera.CxSetScreenParams( H, &Params );

    m_camera.CxSetFrequency( H, 2 ); // 24 Mhz

    // wait 1 sec
    Sleep(1000);
    //
    // start camera
    //
    m_camera.CxSetStreamMode( H, 1 );
    
    Sleep(100);
    //
    //  Get Frames
    //
    m_camera.CxGrabVideoFrame(H, Frame, sizeof(Frame) );
    saveBMP("Frame1.bmp", Frame, 1280, 1024, 24);
    
    m_camera.CxGrabVideoFrame(H, Frame, sizeof(Frame) );
    saveBMP("Frame2.bmp", Frame, 1280, 1024, 24);
    
    m_camera.CxGrabVideoFrame(H, Frame, sizeof(Frame) );
    saveBMP("Frame3.bmp", Frame, 1280, 1024, 24);

    //
    // stop camera
    //
    m_camera.CxSetStreamMode( H, 0 );

    m_camera.CxCloseDevice(H);
    m_camera.Shutdown(); // unloads the dll
}
