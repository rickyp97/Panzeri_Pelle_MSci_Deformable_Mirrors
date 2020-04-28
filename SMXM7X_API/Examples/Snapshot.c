#include <windows.h>
#include <process.h>
#include <stdio.h>

#include "..\SMXM7X.h"

static void SaveFrame(FILE *fp, BYTE *buf, int H, int LineSize) {
    int i;
    for (i = H-1; i>=0; i--) {
        UCHAR *b = buf + i * LineSize;
        fwrite(b,LineSize,1,fp);
    }
}


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
    }
    SaveFrame(fp, (UCHAR *)buf, H, W * bits / 8 );
    // fwrite(buf,InfoHead.biSizeImage,1,fp);
    fclose(fp);
    return TRUE;
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
    fprintf( stderr, "ERROR! %s : %s\n", Title, lpMsgBuf );
    //MessageBox( NULL, (LPCTSTR)lpMsgBuf, Title, MB_OK | MB_ICONINFORMATION );
    // Free the buffer.
    LocalFree( lpMsgBuf );
}


static BYTE Buffer[ MaxFrameSize ];
static BYTE RGB24[ MaxFrameSize * 3 ];

int main(int argc, char *argv[]) {
    int CameraNo;
    float ExpMs;
    DWORD RetSize;
    TFrameParams Params;
    HANDLE H;

    CameraNo = argc == 2 ? atoi( argv[1] ) : 0;

    printf("CameraNo=%d\n", CameraNo );

    // open camera
    H = CxOpenDevice( CameraNo );

    if (H == INVALID_HANDLE_VALUE) {
        error("CxOpenDevice(0)");
        return -1;
    }

    //
    // stop camera !!
    //
    CxSetStreamMode( H, 0 );
    
    //
    // setup Frame Params
    //
    memset( &Params, 0, sizeof(Params) );
    Params.Width  = 1280;
    Params.Height = 1024;
    Params.Decimation = 1;

    if (! CxSetScreenParams( H, &Params ) ) {
        error("! CxSetScreenParams(H,&Params)");
        CxCloseDevice(H);
        return -1;
    }

    //
    // set Frequency
    //
    if (! CxSetFrequency( H, FREQ_16 ) ) {
        error("! CxSetFrequency( H, FREQ_16 )");
        CxCloseDevice(H);
        return -1;
    }

    //
    // set Gain
    //
    if (! CxSetGain( H, 0, 0, 0, 0 ) ) {
        error("! CxSetGain( H, 0 )");
        CxCloseDevice(H);
        return -1;
    }

    //
    // set Snapshot Exposure
    //
    if (! CxSetExposureMs( H, 1.17, &ExpMs ) ) {
        error("! CxSetExposureMs( H, 1.17, &ExpMs )");
        CxCloseDevice(H);
        return -1;    
    }

    //
    // get Snapshot
    //
    if (! CxGetSnapshot( H, 5, FALSE, FALSE, TRUE, Buffer, sizeof(Buffer), &RetSize ) ) {
        error("! CxGetSnapshot( H, 5, FALSE, FALSE, FALSE, Buffer, sizeof(Buffer), &RetSize )");
        CxCloseDevice(H);
        return -1;        
    }
    std::cout << RetSize

    if (RetSize == 0) {
        error("Zero output ! Timeout ?");
        CxCloseDevice(H);
        return -1;        
    }

	CxBayerToRgb( Buffer, Params.Width, Params.Height, 2, (TRgbPix *)RGB24 );

    saveBMP( "snapshot.bmp", Buffer, 1280, 1024, 8);
    saveBMP( "snap24.bmp", RGB24, 1280, 1024, 24 );

    printf("Saved to 'snapshot.bmp' and 'snap24.bmp'\n" );
    
    CxCloseDevice(H);
    return 0;
}
