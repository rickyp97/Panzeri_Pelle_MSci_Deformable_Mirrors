#include <windows.h>
#include <vfw.h>
#include <stdio.h>

#include "..\SMXM7X.h"

const unsigned long IMAGE_SIZE = 1400*1024;

BYTE *frame,*frame4;

int main() {
    TCameraInfo cinfo;
    TFrameParams sinfo;
    HANDLE H = CxOpenDevice(0);
    
    if (H == INVALID_HANDLE_VALUE ) {
        perror("Error open driver !");
        return 1;
    }

    CxGetCameraInfo(H, &cinfo );

    printf(
        "Camera '%s' found : SensorType=%X MaxWidth=%d MaxHeight=%d\n",
        cinfo.DeviceName,
        cinfo.SensorType,
        cinfo.MaxWidth,
        cinfo.MaxHeight
    );

    CxGetScreenParams(H, &sinfo );

    if (sinfo.Width > cinfo.MaxWidth ) {
        sinfo.Width = cinfo.MaxWidth;
    }
    if (sinfo.Height > cinfo.MaxHeight ) {
        sinfo.Height = cinfo.MaxHeight;
    }
    sinfo.Height = 240;//480;
    sinfo.Width = 320; // 640;
    sinfo.StartX = 0;
    sinfo.StartY = 0;
    sinfo.Decimation = 1;
    sinfo.MirrorV = 0;
    sinfo.MirrorH = 0;

    CxSetScreenParams(H, &sinfo );

    CxActivateScreenParams(H);

    CxSetFrequency(H,2);
    CxSetStreamMode(H,1);
    CxCloseDevice(H);

// Init AVI

    char szAVIFile[] = "test.avi";
    AVIFileInit();
    PAVIFILE pafOutput;
    if ( AVIFileOpen (&pafOutput, szAVIFile, OF_WRITE | OF_CREATE, 0) != 0) {
        AVIFileExit();
        return 1;
    }

// Fill in the AVI Stream Info structure

    AVISTREAMINFO asiOutput;
    ZeroMemory (&asiOutput, sizeof AVISTREAMINFO);
    asiOutput.fccType = streamtypeVIDEO;
    asiOutput.dwScale = 1;
    asiOutput.dwRate = 25;
    asiOutput.dwLength = 10; // 10 sec
    asiOutput.dwSampleSize = sinfo.Width * sinfo.Height;
    asiOutput.rcFrame.right = sinfo.Width;
    asiOutput.rcFrame.bottom = sinfo.Height;
    strcpy (asiOutput.szName, "Video #1");

// Create a new AVI Stream

    PAVISTREAM pasOutput;
    if (AVIFileCreateStream(pafOutput, &pasOutput, &asiOutput) != 0) {
        AVIFileRelease (pafOutput);
        AVIFileExit();
        return 1;
    }

// Fill in the information of a new Bitmap Info Header. this will be used
// to set the format of the AVI stream.
                
    BITMAPINFOHEADER bmh;
    ZeroMemory (&bmh, sizeof BITMAPINFOHEADER);
    bmh.biSize = sizeof BITMAPINFOHEADER;
    bmh.biPlanes = 1;
    bmh.biBitCount = 24;
    bmh.biWidth = sinfo.Width;
    bmh.biHeight = sinfo.Height;
    bmh.biCompression = 0; // RI_RGB;
    bmh.biSizeImage = sinfo.Width * sinfo.Height * 3;

    if (AVIStreamSetFormat (pasOutput, 0, &bmh, sizeof(BITMAPINFOHEADER) ) != 0) {
        AVIStreamRelease (pasOutput);
        AVIFileRelease (pafOutput);
        AVIFileExit();
        return 1;
    }

////////////////////////////////

    H = CxOpenDevice(0);
    if (H == INVALID_HANDLE_VALUE ) {
        perror("Error open driver !");
        return 1;
    }

    frame = new BYTE [ IMAGE_SIZE ];
    frame4 = new BYTE [ IMAGE_SIZE * 3 ];
    

    for(unsigned long i = 0; i < (asiOutput.dwLength * asiOutput.dwRate) / asiOutput.dwScale; i++) {

    printf("%d\r",i);
//        printf("Frame %d start", i);
        CxGetScreenParams(H,&sinfo);

    printf(
        " StartX=%d StartY=%d Width=%d Height=%d Decimation=%d ColorDeep=%d MirrorV=%d MirrorH=%d ",
        sinfo.StartX,
        sinfo.StartY,
        sinfo.Width,
        sinfo.Height,
        sinfo.Decimation,
        sinfo.ColorDeep,
        sinfo.MirrorV,
        sinfo.MirrorH
    );
        printf(" param-");

        CxGrabVideoFrame(H, frame, IMAGE_SIZE);
        printf(">");
        UCHAR *p = frame;
        UCHAR *p2 = frame4;

        CxBayerToRgb( frame, sinfo.Width, sinfo.Height, 2, (TRgbPix *)frame4 );
/*
        for(unsigned long j = 0; j < sinfo.Width * sinfo.Height; j++, p++ ) {
            p2[0] = *p;
            p2[1] = *p;
            p2[2] = *p;
            p2 += 3;
        }
*/
        printf(" [0] = %d ", frame[0] );
        long lSamplesWritten, lBytesWritten;
        if ( AVIStreamWrite(pasOutput,i,1,frame4,bmh.biSizeImage,AVIIF_KEYFRAME,&lSamplesWritten, &lBytesWritten) != AVIERR_OK ) {
            break;
        } else {
//            printf(" lSamplesWritten=%d, lBytesWritten=%d", lSamplesWritten, lBytesWritten);
        }    
        printf(" finish\n");
        
    }
    CxCloseDevice(H);
    
    AVIStreamRelease(pasOutput);
    AVIFileRelease(pafOutput);
    AVIFileExit();
    
    delete frame4;
    delete frame;

    return 0;
}
