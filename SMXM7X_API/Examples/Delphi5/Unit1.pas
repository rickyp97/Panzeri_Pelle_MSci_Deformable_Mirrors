unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Spin, SMXM7X, ExtCtrls, ComCtrls, AllocMemory;

Const
//    FRAME_WIDTH = 1280;
//    FRAME_HEIGHT = 1024;

    FRAME_WIDTH = 640;
    FRAME_HEIGHT = 480;

type
  TForm1 = class(TForm)
    btSnapshot: TButton;
    btCancelSnapshot: TButton;
    cbExtTrgEnabled: TCheckBox;
    spnTimeout: TSpinEdit;
    Label1: TLabel;
    Message: TLabel;
    GroupBox1: TGroupBox;
    rbPositive: TRadioButton;
    rbNegative: TRadioButton;
    ComboBox1: TComboBox;
    Label2: TLabel;
    Timer1: TTimer;
    ComboBox2: TComboBox;
    Label3: TLabel;
    tbExposure: TTrackBar;
    lbExp: TLabel;
    cbSave: TCheckBox;
    Label4: TLabel;
    cbGain: TComboBox;
    trB: TTrackBar;
    trC: TTrackBar;
    lbC: TLabel;
    lbB: TLabel;
    procedure btSnapshotClick(Sender: TObject);
    procedure DisplayMessage( Str : String);
    procedure FormCreate(Sender: TObject);
    procedure btCancelSnapshotClick(Sender: TObject);
    procedure ComboBox1Change(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Timer1Timer(Sender: TObject);
    procedure ComboBox2Change(Sender: TObject);
    procedure tbExposureChange(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure cbGainChange(Sender: TObject);
    procedure trBChange(Sender: TObject);
    procedure trCChange(Sender: TObject);
  private
    { Private declarations }
  public
  { Public declarations }
    FSnapshotLoop : Boolean;
    FSnapshotCounter : Integer;
    CameraNo : Integer;

    hLoopThread : THandle;
    SavedFrames, CurrFrames : Dword;

    // for memory
    FramesPtr : PChar;
    FramesNum : Integer;
    FramesIdx : Integer;

    // Image corrections
    B,C,G : Integer;

  end;

Type
  frameArray = array [0..1400*1024-1] of byte;

var
  Form1: TForm1;
  SnapshotFrame : frameArray;

implementation

uses Unit2;

{$R *.dfm}


Procedure SaveAsBitmap(Fn:string; pBuf : pointer; ScW,ScH:integer; ClDeep:integer);
var
  i         : integer;
  f         : file;
  DibPixels : pchar;
  P : PChar;
  ColorFactor : integer;

  DibSize   : integer;
  Dib       : packed record
     Hdr    : TBitmapInfoHeader;
     Colors : array[0..255] of longint;
  end;

  FileHdr   : packed record
    SgBM    : array [0..1] of char;
    TotalSz : integer;
    _rez    : integer;
    HdrSz   : integer;
  end;

Begin
  { make }
  FillChar(Dib.Hdr,sizeof(Dib.Hdr),0);
  if ClDeep=8 then begin
     DibPixels:=CxBayerToRgb(pBuf, ScW, ScH, 0, FrameBuf); // mono !!!
  end else begin
     DibPixels:=CxBayerToRgb(pBuf, ScW, ScH, 2, FrameBuf);
  end;
  DibSize:=ScW*ScH*3;
  ColorFactor:=3;

  Dib.Hdr.biSize:=sizeof(Dib.Hdr);
  Dib.Hdr.biWidth:=ScW;
  Dib.Hdr.biHeight:=ScH;
  Dib.Hdr.biPlanes:=1;
  Dib.Hdr.biBitCount:=24;
  Dib.Hdr.biCompression:=bi_RGB;
  Dib.Hdr.biSizeImage:=DibSize;
  Dib.Hdr.biXPelsPerMeter := Round(GetDeviceCaps(GetDC(0), LOGPIXELSX) * 39.3701);
  Dib.Hdr.biYPelsPerMeter := Round(GetDeviceCaps(GetDC(0), LOGPIXELSY) * 39.3701);
  { store }
  FileHdr.SgBM:='BM';
  FileHdr._rez:=0;
  FileHdr.HdrSz:=$36;
  FileHdr.TotalSz:=DibSize+FileHdr.HdrSz;
  If Fn='' then Exit;//Fn:=GenerateNewFileName('',1,'.bmp');
  AssignFile(f,Fn);
  Rewrite(f,1);
  BlockWrite(f,FileHdr,sizeof(FileHdr));
  BlockWrite(f,Dib.Hdr,sizeof(Dib.Hdr));
  for i := ScH-1 downto 0 do begin
    p := DibPixels + ScW * i * ColorFactor;
    BlockWrite(f, p^, ScW*ColorFactor);
  end;
  CloseFile(f);
end;

procedure TForm1.FormCreate(Sender: TObject);
Var
    H : THandle;
    Params : TCxScreenParams;
    MinExposure, MaxExposure:Integer;
    ExpMs:Single;
begin
    FSnapshotLoop := False;
    FSnapshotCounter := 0;
    CameraNo := 0;
    hLoopThread := 0;
    SavedFrames := 0;
    CurrFrames := 0;
    try
        // Open device
        H := CxOpenDevice(CameraNo);
        if H <> INVALID_HANDLE_VALUE then begin
			CxGetScreenParams(H,Params);
			Params.Width := FRAME_WIDTH;
			Params.Height := FRAME_HEIGHT;
			Params.StartX := 0;
			Params.StartY := 0;
			Params.Decimation := 1;
			CxSetScreenParams(H,Params);
            CxSetGain(H, 0,0,0,0);
            CxSetFrequency(H, 1); // 24 Mhz
            CxGetExposureMinMax(H,MinExposure, MaxExposure);
            CxSetExposure(H,MinExposure);
            CxGetExposureMs(H,ExpMs);
            lbExp.Caption := Format('Exposure: %6.2F ms',[ ExpMs ] );
            tbExposure.Min := MinExposure;
            tbExposure.Max := MaxExposure;
            tbExposure.Position := MinExposure;
            B := 127;
            C := 64;
            G := 0;
            trB.Position := B;
            trC.Position := C;
            lbB.Caption := Format('Brightness: %d',[ B ] );
            lbC.Caption := Format('Contrast: %d',[ C ] );
            CxSetBrightnessContrastGamma( H, B, C, G);
            CxCloseDevice(H);
         end;
    except
    // leave default setting
    end;

    FramesPtr := nil;
    FramesNum := 0;
    FramesIdx := 0;

    AllocFrames( FRAME_WIDTH * FRAME_HEIGHT, FramesPtr, FramesNum);

    if FramesNum = 0 then begin
        DisplayMessage('Alloc of frames failed!');
        FramesPtr := @SnapshotFrame;
        FramesNum := 0;
    end else begin
        DisplayMessage('Alloc ' + IntToStr(FramesNum) + ' frames');
    end;

    end;

procedure TForm1.DisplayMessage( Str : String);
begin
    try
        Message.Caption := Str;
    except
        // leave default setting
    end;
end;

procedure TForm1.btSnapshotClick(Sender: TObject);

    procedure LoopSnapshotThreadProc(Var Foo); Stdcall;
    Var
        H : THandle;
        Status, Ok : Boolean;
        Params : TCxScreenParams;
        RetLen:DWORD;
        FrameP : PChar;
    begin

        Form1.FSnapshotLoop := True;
        Form1.btCancelSnapshot.Enabled := True;
        Form1.btSnapshot.Enabled := False;

        while Form1.FSnapshotLoop do begin
            Application.ProcessMessages;
            try
                H := CxOpenDevice(Form1.CameraNo);
                if H <> INVALID_HANDLE_VALUE then begin
                    Ok := False;

			        CxGetScreenParams(H,Params);
			        Params.Width := FRAME_WIDTH;
			        Params.Height := FRAME_HEIGHT;
			        Params.StartX := 0;
			        Params.StartY := 0;
			        Params.Decimation := 1;
			        CxSetScreenParams(H,Params);

                    FrameP := Form1.FramesPtr + FRAME_WIDTH*FRAME_HEIGHT*Form1.FramesIdx;

                    Status := CxGetSnapshot(
                        H,
                        Form1.spnTimeout.Value,
                        Form1.cbExtTrgEnabled.Checked,
                        Form1.rbPositive.Checked,
                        True,
                        FrameP, //@SnapshotFrame,
                        FRAME_WIDTH*FRAME_HEIGHT,// sizeof(SnapshotFrame),
                        RetLen
                    );

                    Inc(Form1.CurrFrames);

                    if not Status then begin
                        Form1.DisplayMessage( 'Snapshot Status: Error!')
                    end else begin
                        if RetLen = 0 then
                            Form1.DisplayMessage( 'Snapshot Status: Empty Frame (Timeout ?)!')
                        else
                            Ok := True;
                    end;

                    // Show snapshot
                    if Ok then begin
                        CxGetScreenParams(H,Params);
                        Params.Width := Params.Width div Params.Decimation;
                        Params.Height := Params.Height div Params.Decimation;
                        SSForm.ShowFrame( FrameP{@SnapshotFrame}, Params.Width, Params.Height, Params.ColorDeep );
                        Form1.DisplayMessage( IntToStr(Form1.FramesIdx+1) + ' of ' +  IntToStr(Form1.FramesNum) );
                        if Form1.cbSave.Checked then
                            SaveAsBitmap( IntToStr(Form1.CurrFrames) + '.bmp', FrameP,  Params.Width, Params.Height, Params.ColorDeep);
                            
                        Inc(Form1.FramesIdx);
                        if Form1.FramesIdx >= Form1.FramesNum then Form1.FramesIdx := 0;
                    end else begin
                        SSForm.Hide;
                    end;

                    CxCloseDevice(H);
                end else begin
                    Form1.DisplayMessage('Error open Camera #0!');
                    Sleep(300);
                end;
            except
            // leave default setting
            end;
        end; // while FSnapshotLoop do
    end; // LoopSnapshotThreadProc

Var
    ThreadId : Dword;
Begin
    if hLoopThread = 0 then begin
        hLoopThread := CreateThread(Nil,0,@LoopSnapshotThreadProc,@Self,CREATE_SUSPENDED,ThreadId);
    end;
    if hLoopThread <> 0 then begin
        SetThreadPriority(hLoopThread,THREAD_PRIORITY_IDLE);
        ResumeThread(hLoopThread);
    end;
    Form1.FSnapshotLoop := True;
    Form1.btCancelSnapshot.Enabled := True;
    Form1.btSnapshot.Enabled := False;
End;


procedure TForm1.btCancelSnapshotClick(Sender: TObject);
begin
    FSnapshotLoop := False;
    if hLoopThread <> 0 then begin
        SuspendThread(hLoopThread);
    end;
    btCancelSnapshot.Enabled := False;
    btSnapshot.Enabled := True;
    SSForm.Hide;
    Form1.DisplayMessage( '' );
end;

procedure TForm1.ComboBox1Change(Sender: TObject);
begin
    CameraNo := ComboBox1.ItemIndex;
end;

procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
begin

    if hLoopThread <> 0 then begin
        TerminateThread(hLoopThread,0);
        CloseHandle(hLoopThread);
        hLoopThread := 0;
    end;

    FreeFrames( FRAME_WIDTH * FRAME_HEIGHT, FramesPtr, FramesNum);

end;

procedure TForm1.Timer1Timer(Sender: TObject);
begin
    SSForm.Caption := IntToStr( CurrFrames - SavedFrames ) + ' fps';
    SavedFrames := CurrFrames;
end;

procedure TForm1.ComboBox2Change(Sender: TObject);
Var
    H:THandle;
    MinExposure, MaxExposure:Integer;
begin
    try
        H := CxOpenDevice(CameraNo);
        if H <> INVALID_HANDLE_VALUE then begin
            CxSetFrequency(H, ComboBox2.ItemIndex);
            CxGetExposureMinMax(H,MinExposure, MaxExposure);
            tbExposure.Max := MaxExposure;
            tbExposure.Min := MinExposure;
            CxCloseDevice(H);
            tbExposureChange(nil);
        end;
    finally
    end;
end;

procedure TForm1.tbExposureChange(Sender: TObject);
Var
    H:THandle;
    ExpMs:Single;
begin
    try
        H := CxOpenDevice( CameraNo );
        if H <> INVALID_HANDLE_VALUE then begin
            CxSetExposure(H, tbExposure.Position);
            CxGetExposureMs(H,ExpMs);
            lbExp.Caption := Format('Exposure: %6.2F ms',[ ExpMs ] );
            CxCloseDevice(H);
        end;
    finally
    end;
end;


procedure TForm1.FormKeyPress(Sender: TObject; var Key: Char);
begin
    if (Key=#27) and FSnapshotLoop then begin
        btCancelSnapshotClick(nil);
    end;
end;

procedure TForm1.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
    if (Key=VK_ESCAPE) and FSnapshotLoop then begin
        btCancelSnapshotClick(nil);
    end;
end;

procedure TForm1.cbGainChange(Sender: TObject);
Var
    H:THandle;
begin
    try
        H := CxOpenDevice(CameraNo);
        if H <> INVALID_HANDLE_VALUE then begin
            CxSetGain(H, cbGain.ItemIndex,cbGain.ItemIndex,cbGain.ItemIndex,cbGain.ItemIndex);
            CxCloseDevice(H);
        end;
    finally
    end;
end;

procedure TForm1.trBChange(Sender: TObject);
Var
    H:THandle;
begin
    try
        H := CxOpenDevice(CameraNo);
        if H <> INVALID_HANDLE_VALUE then begin
            B := trB.Position;
            CxSetBrightnessContrastGamma( H, B, C, G);
            CxCloseDevice(H);
            lbB.Caption := Format('Brightness: %d',[ B ] );
        end;
    finally
    end;
end;

procedure TForm1.trCChange(Sender: TObject);
Var
    H:THandle;
begin
    try
        H := CxOpenDevice(CameraNo);
        if H <> INVALID_HANDLE_VALUE then begin
            C := trC.Position;
            CxSetBrightnessContrastGamma( H, B, C, G);
            CxCloseDevice(H);
            lbC.Caption := Format('Contrast: %d',[ C ] );
        end;
    finally
    end;
end;

End.

