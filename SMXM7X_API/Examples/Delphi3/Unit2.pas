unit Unit2;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs,SMXM7X;

type
  TSSForm = class(TForm)
    procedure FormPaint(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    pBuf : pointer;
    FWidth : Integer;
    FHeight : Integer;
    FClDeep : Integer;
    procedure ShowFrame(Frame:Pointer;W,H,ColorDeep:Integer);
  end;

var
  SSForm: TSSForm;
  FrameBuf : TRgbPixArray;

implementation

{$R *.dfm}


procedure TSSForm.ShowFrame(Frame:Pointer;W,H,ColorDeep:Integer);
Begin
    pBuf := Frame;
    FWidth := W;
    FHeight := H;
    FClDeep := ColorDeep;
    WindowState := wsNormal;
    Show;
    FormPaint(nil);
End;


Procedure DrawCxBitmap(DC:THandle; pBuf : pointer; ScW:integer; ScH:integer; ClDeep:integer; dx,dy:integer);
Var
  DibPixels : pchar;
  DibSize   : integer;
 FDib : packed record
   Hdr    : TBitmapInfoHeader;
   Colors : array[0..255] of longint;
 end;
begin
  if ClDeep=8 then begin
    DibPixels:=pBuf;
    DibSize :=ScW*ScH;
  end else begin
    DibPixels:=CxBayerToRgb(pBuf,ScW,ScH,2{Bilinear},FrameBuf);
    DibSize :=ScW*ScH*3;
  end;

  FDib.Hdr.biSize:=sizeof(FDib.Hdr);
  FDib.Hdr.biWidth:=ScW;
  FDib.Hdr.biHeight:=-ScH;
  FDib.Hdr.biPlanes:=1;
  FDib.Hdr.biBitCount:=ClDeep;
  FDib.Hdr.biCompression:=bi_RGB;
  FDib.Hdr.biSizeImage:=DibSize;
  FDib.Hdr.biXPelsPerMeter:=23622;
  FDib.Hdr.biYPelsPerMeter:=23622;

  SetDIBitsToDevice(DC, dx, dy, ScW, ScH, 0, 0, 0, ScH, DibPixels, TBitMapInfo((@FDib)^), DIB_RGB_COLORS);

end;


procedure TSSForm.FormPaint(Sender: TObject);
Var
    hdc : THandle;
    DibPixels : pchar;
    cnt, DibSize   : integer;
    FDib : packed record
        Hdr    : TBitmapInfoHeader;
        Colors : array[0..255] of longint;
    end;

    Function ToGray(n:integer) : longint;
    Asm
    	// Result := n + n * 256 + n * 256 * 256
        mov   ah,al
        shl   eax,8
        mov   al,ah
    End;
    
begin
    ClientWidth := FWidth;
    ClientHeight := FHeight;

    if FClDeep=8 then begin
        DibPixels:=pBuf;
        DibSize :=FWidth*FHeight;
        FillChar(FDib.Hdr, sizeof(FDib.Hdr), 0);
        for cnt:=0 to 255 do
            FDib.Colors[cnt]:=ToGray(cnt);
    end else begin
        DibPixels:=CxBayerToRgb(pBuf,FWidth,FHeight,2{Bilinear},FrameBuf);
        DibSize :=FWidth*FHeight*3;
    end;

    FDib.Hdr.biSize:=sizeof(FDib.Hdr);
    FDib.Hdr.biWidth:=FWidth;
    FDib.Hdr.biHeight:=-FHeight;
    FDib.Hdr.biPlanes:=1;
    FDib.Hdr.biBitCount:=FClDeep;
    FDib.Hdr.biCompression:=bi_RGB;
    FDib.Hdr.biSizeImage:=DibSize;
    FDib.Hdr.biXPelsPerMeter:=23622;
    FDib.Hdr.biYPelsPerMeter:=23622;

    hdc := GetDC(Handle);
    SetDIBitsToDevice(hdc, 0, 0, FWidth, FHeight, 0, 0, 0, FHeight, DibPixels, TBitMapInfo((@FDib)^), DIB_RGB_COLORS);
    ReleaseDC(Handle,hdc);
end;


end.
