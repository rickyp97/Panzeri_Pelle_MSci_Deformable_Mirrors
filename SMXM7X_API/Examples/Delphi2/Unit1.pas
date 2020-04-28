unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls,SMXM7X, ComCtrls;

type
  TForm1 = class(TForm)
    ViewFrame: TPanel;
    btRun: TButton;
    trExp: TTrackBar;
    Label1: TLabel;
    cbCameraNo: TComboBox;
    Label2: TLabel;
    cbGain: TComboBox;
    Label3: TLabel;
    Timer1: TTimer;
    lbFPS: TLabel;
    Label4: TLabel;
    cbFreq: TComboBox;
    Button1: TButton;
    procedure btRunClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure trExpChange(Sender: TObject);
    procedure cbCameraNoChange(Sender: TObject);
    procedure cbGainChange(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure cbFreqChange(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    Running : Boolean;
    CameraNo : Integer;
    hThread : THandle;
    Frames : Integer;
    SavedFrames : Integer;

    procedure StartCamera;
    procedure StopCamera;
    function AutoExposure : boolean;
  end;

var
  Form1: TForm1;
  Frame : Array [0..1024*1400-1] of Byte;
  FrameBuf : TRgbPixArray;

implementation

{$R *.dfm}

procedure TForm1.btRunClick(Sender: TObject);
begin
    if Running then begin
        StopCamera;
    end else begin
        StartCamera;
    end;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
    Running := False;
    CameraNo := 0;
    btRun.Caption := 'Start';
    hThread := INVALID_HANDLE_VALUE;
    Frames := 0;
    SavedFrames := 0;
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
    if Running then begin
        Running := False;
        StopCamera;
    end;
end;

Function ToGray(n:integer) : longint;
Asm
  mov   ah,al
  shl   eax,8
  mov   al,ah
End;


procedure ThreadProc(Form1:TForm1); Stdcall;
Var
    H, hdc : THandle;
//    pFrame : Pointer;
    FDib : packed record
        Hdr    : TBitmapInfoHeader;
        Colors : array[0..255] of longint;
     end;
    DibPixels : pchar;
    DibSize   : integer;
    FrW : integer;
    FrH  : integer;
    i : Integer;
    ClDeep   : integer;
    Pm       : TCxScreenParams;
begin
    for i := 0 to 255 do begin
        FDib.Colors[i] := ToGray(i);
    end;
    while Form1.Running do begin
        H := CxOpenDevice( Form1.CameraNo );
        if H <> INVALID_HANDLE_VALUE then begin
            CxGetScreenParams(H,Pm);
            if CxGrabVideoFrame( H, @Frame, sizeof(Frame)) then begin
//////////////////////////////////////////////////////////////////////
            FrW := Pm.Width div Pm.Decimation;
            FrH := Pm.Height div Pm.Decimation;
            ClDeep := Pm.ColorDeep; // ClDeep := 24; // debug
            if ClDeep=8 then begin
                DibPixels := @Frame;
                DibSize := FrW*FrH;
            end else begin
                DibPixels:= CxBayerToRgb(@Frame,FrW,FrH,1,FrameBuf);
                DibSize := FrW*FrH*3;
            end;

            FDib.Hdr.biSize:=sizeof(FDib.Hdr);
            FDib.Hdr.biWidth:=FrW;
            FDib.Hdr.biHeight:=-FrH;
            FDib.Hdr.biPlanes:=1;
            FDib.Hdr.biBitCount:=ClDeep;
            FDib.Hdr.biCompression:=bi_RGB;
            FDib.Hdr.biClrUsed := 256;
            FDib.Hdr.biClrImportant := 0;
            FDib.Hdr.biSizeImage:=DibSize;
            FDib.Hdr.biXPelsPerMeter := 0;
            FDib.Hdr.biYPelsPerMeter := 0;

            if (Form1.ViewFrame.ClientWidth <> FrW) or (Form1.ViewFrame.ClientHeight <> FrH ) then begin
                Form1.ViewFrame.ClientWidth := FrW;
                Form1.ViewFrame.ClientHeight := FrH;
            end;

            hdc := GetDC(Form1.ViewFrame.Handle);
    		SetDIBitsToDevice(hdc, 0, 0, FrW, FrH, 0, 0, 0, FrH, DibPixels, TBitMapInfo((@FDib)^), DIB_RGB_COLORS );
            //SetStretchBltMode(hdc,COLORONCOLOR);
            //StretchDIBits(hdc,0,0,FrW,FrH,0,0,FrW,FrH,DibPixels,TBitMapInfo((@FDib)^),DIB_RGB_COLORS,SRCCOPY);
            ReleaseDC(Form1.ViewFrame.Handle,hdc);
            Inc(Form1.Frames);
//////////////////////////////////////////////////////////////////////
            end;
            CxCloseDevice(H);
        end else begin
            break;
        end;
    end;
end;


procedure TForm1.StartCamera;
Var
    H : THandle;
    ThreadId : Dword;
    Pm       : TCxScreenParams;
    MinExp, MaxExp : Integer;
begin
    H := CxOpenDevice( Form1.CameraNo );
    if H = INVALID_HANDLE_VALUE then begin
        StopCamera;
        Exit;
    end else begin
        CxGetScreenParams(H,Pm);
        Pm.StartX := 0;
        Pm.StartY := 0;
        Pm.Width := 640;
        Pm.Height := 480;
        Pm.Decimation := 1;
        CxSetScreenParams(H,Pm);
        CxSetStreamMode(H, 1);
        CxGetExposureMinMax(H,MinExp,MaxExp);
        trExp.Max := MaxExp;
        trExp.Min := MinExp;
        trExp.Position := MinExp;
        CxSetExposure(H,MinExp);
        CxCloseDevice(H);
    end;
    Running := True;
    hThread := CreateThread(Nil,0,@ThreadProc,Self,CREATE_SUSPENDED,ThreadId);
    if hThread <> 0 then begin
        SetThreadPriority(hThread,THREAD_PRIORITY_IDLE);
        ResumeThread(hThread);
    end;
    btRun.Caption := 'Stop';
end;

procedure TForm1.StopCamera;
Var
    H : THandle;
begin
    H := CxOpenDevice( Form1.CameraNo );
    if H <> INVALID_HANDLE_VALUE then begin
        CxSetStreamMode(H, 0);
        CxCloseDevice(H);
    end;
    Running := False;
    if hThread <> INVALID_HANDLE_VALUE then begin
        TerminateThread(hThread,0);
    end;
    hThread := INVALID_HANDLE_VALUE;
    ViewFrame.Caption := 'Stopped';
    ViewFrame.Repaint;
    btRun.Caption := 'Start';
end;


procedure TForm1.trExpChange(Sender: TObject);
Var
    H : THandle;
begin
    H := CxOpenDevice( Form1.CameraNo );
    if H <> INVALID_HANDLE_VALUE then begin
        CxSetExposure(H, trExp.Position);
        CxCloseDevice(H);
    end;
end;

procedure TForm1.cbCameraNoChange(Sender: TObject);
Var
    IsRunning : Boolean;
begin
    IsRunning := Running;
    StopCamera;
    CameraNo := cbCameraNo.ItemIndex;
    if IsRunning then
        StartCamera;
end;


procedure TForm1.cbGainChange(Sender: TObject);
Var
    H : THandle;
//    Value : Dword;
//    Val : Byte;
begin
    try
        H := CxOpenDevice(CameraNo);
        if (H <> INVALID_HANDLE_VALUE) then begin
            CxSetAllGain( H, cbGain.ItemIndex );
            CxCloseDevice(H);
        end;
    except
    end;
end;

procedure TForm1.Timer1Timer(Sender: TObject);
Var
    Delta : Integer;
begin
    Delta := Frames - SavedFrames;
    SavedFrames := Frames;
    lbFPS.Caption := Format( '%6.2f fps', [Delta*1000 / Timer1.Interval] );
end;

procedure TForm1.cbFreqChange(Sender: TObject);
Var
    H : THandle;
begin
    try
        H := CxOpenDevice(CameraNo);
        if (H <> INVALID_HANDLE_VALUE) then begin
            CxSetFrequency( H, cbFreq.ItemIndex );
            CxCloseDevice(H);
        end;
    except
    end;
end;


function TForm1.AutoExposure : boolean;
const
    MaxFreq = 9;
    Freqs : Array [0..MaxFreq] of single = (
        48.0,
        40.0,
        24.0,
        20.0,
        16.0,
        13.333,
        12.0,
        10.0,
        8.0,
        6.66
    );
var Hndle : integer;
    A : array[0..255] of integer;
    Params : TCxScreenParams;
    val, W, H, i : integer;

    CurE, NewE : single;

    MinE, MaxE : single;

    CurrentFreq, NewFreq : byte;
    MaxExps : array[0..MaxFreq] of single;

{==========================================}

  procedure _FormHistogram;
  var ii : Integer;
//  ww,hh,pp : integer;
  begin
    // zero memory
    ii:=integer(@A);
//    ww:=W;
//    hh:=H;
//    pp:=integer(pFrameBuf);
    asm
      mov  ebx, ii
      mov  edi, ebx
      mov  ecx, 256
      xor  eax, eax
      rep  stosd
    end;

    for ii:=0 to W*H do inc(A[Frame[ii]]);
  end;

var
  SaturationPercent : single;
  MaxPointBrightness : byte;
  itcnt : integer;

const
  LT = 32;
  HT = 250;
  SATURATION_LIMIT_PERCENT = 0.01; //1.0;
  SHURE_POINTS_PERCENT = 0.01; // percent to know fo shure if there is such points

begin

  Result:=False;

  if hThread <> 0 then begin
        SuspendThread(hThread);
  end;

  Hndle := CxOpenDevice(CameraNo);
  if (Hndle=-1) then Exit;

  Screen.Cursor:=crHourGlass;

  try
    CxGetScreenParams(Hndle, Params);
    CxGetExposureMs(Hndle, CurE);
    CxGetExposureMinMaxMs(Hndle, minE, maxE);
    W:=Params.Width div Abs(Params.Decimation);
    H:=Params.Height div Abs(Params.Decimation);
    newE := curE;

    CxGetFrequency(Hndle, CurrentFreq);
    MaxExps[CurrentFreq] := maxE;
    // form max exposures array to calculate frequency jump
    for i := 0 to MaxFreq do
        MaxExps[i] := maxE * Freqs[CurrentFreq] / Freqs[i];

    // new GENIOUS half-iterative AE method

    itcnt := 0;
    while itcnt<100 do begin

      if itcnt>0 then begin
        CxSetExposureMs(Hndle, newE, curE);

        CxGrabVideoFrame(Hndle, @Frame, W*H);
        CxGrabVideoFrame(Hndle, @Frame, W*H);
        CxGrabVideoFrame(Hndle, @Frame, W*H);
      end;

      Inc(itcnt);

      // grab the frame
      CxGrabVideoFrame(Hndle, @Frame, W*H);

      // analyze the % of saturation
      _FormHistogram();
      SaturationPercent := A[255]*100 / (W*H);

      if SaturationPercent >= SATURATION_LIMIT_PERCENT then begin
        // there is some saturation
        maxE := curE; // set current max limit

        // count newE according to saturation %

        if SaturationPercent > 66 then
          newE := minE + (maxE - minE)*0.33
        else if SaturationPercent<33 then
          newE := minE + (maxE - minE)*0.66
        else
          newE := minE + (maxE - minE)*0.50;

        Continue;
      end;

      // get max shure point brightness
      MaxPointBrightness := 0;
      for i:=254 downto 0 do begin
        if (A[i]*100/(W*H)) > SHURE_POINTS_PERCENT then begin
          MaxPointBrightness := i;
          break;
        end;
      end;

      if MaxPointBrightness < LT then begin

        minE:=curE; // set current min limit

        // rather dark picture
        if MaxPointBrightness = 0 then
          newE := curE + (maxE - curE)/2
        else begin
          {!!!}newE := curE * (1.1 * LT/MaxPointBrightness);
          if newE >= maxE then begin
            CxSetExposureMs(Hndle, maxE, curE);
            Break;
          end;
        end;
        Continue;
      end;

      // Assume that all OK. Calculate and set new exposure.

      newE:=curE * (HT/MaxPointBrightness);

      // calculate the frequency and set it if necessary
      if newE > MaxE then begin
        NewFreq := 9;
        for i:=CurrentFreq to MaxFreq do begin
          if MaxExps[i]>=NewE then begin
            NewFreq:=i;
            Break;
          end;
        end;

        // set new freq
        if (NewFreq <> CurrentFreq) then begin
          CxSetFrequency(Hndle, NewFreq);
        end;

      end;

      CxSetExposureMs(Hndle, newE, curE);
      Break;
    end;

  finally
    CxCloseDevice(Hndle);
    Screen.Cursor:=crDefault;
  end;

  if hThread <> 0 then begin
        ResumeThread(hThread);
  end;
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
    Button1.Enabled := False;
    Autoexposure;
    Button1.Enabled := True;
end;

end.
