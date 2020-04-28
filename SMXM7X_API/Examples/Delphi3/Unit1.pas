unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Spin, SMXM7X;

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
    procedure btSnapshotClick(Sender: TObject);
    procedure DisplayMessage( Str : String);
    procedure FormCreate(Sender: TObject);
    procedure btCancelSnapshotClick(Sender: TObject);
    procedure ComboBox1Change(Sender: TObject);
  private
    { Private declarations }
  public
    FSnapshotCounter : Integer;
    CameraNo : Integer;
    { Public declarations }
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
    Exp : Single;
begin
    FSnapshotCounter := 0;
    CameraNo := 0;
    try
        // Open device
        H := CxOpenDevice(CameraNo);
        if H <> INVALID_HANDLE_VALUE then begin
			CxGetScreenParams(H,Params);
			Params.Width := 1280;
			Params.Height := 1024;
			Params.StartX := 0;
			Params.StartY := 0;
			Params.Decimation := 1;
			CxSetScreenParams(H,Params);
			//CxSetStreamMode(H,1);
			//CxSetExposureMs(H, 1.1, Exp);
        	//CxSetFrequency(H,1); //
        	//Sleep(300);
			//CxSetStreamMode(H,0);
            CxCloseDevice(H);
         end;
    except
    // leave default setting
    end;
end;


procedure TForm1.DisplayMessage( Str : String);
begin
    Message.Caption := Str;
end;

procedure TForm1.btSnapshotClick(Sender: TObject);
Var
    H : THandle;
    Ok : Boolean;
    Params : TCxScreenParams;
    FName : String;
Type
    TSnapshotThreadParams = record
        hEvent : THandle;
        H:THandle;
        Timeout:Integer;
        ExtTrgEnabled:Boolean;
        ExtTrgPolarity : Boolean;
        SnapshotMode:Boolean;
        Buffer:Pointer;
        BufSize:Integer;
        RetLen:DWORD;
        Status:Boolean;
    end;
Var
    SnapshotThreadParams : TSnapshotThreadParams;
    State, ThreadId : Dword;
    hThread : THandle;

    procedure GetSnapshotThreadProc(Var Params:TSnapshotThreadParams); Stdcall;
    begin
        try
            Params.Status := CxGetSnapshot(
                Params.H,
                Params.Timeout,
                Params.ExtTrgEnabled,
                Params.ExtTrgPolarity,
                Params.SnapshotMode,
                Params.Buffer,
                Params.BufSize,
                Params.RetLen
            );
        except
        end;
        if Params.hEvent<>0 then
            SetEvent(Params.hEvent);
    end;

Begin
    DisplayMessage('');
    try
        // Open device
        H := CxOpenDevice(CameraNo);
        if H <> INVALID_HANDLE_VALUE then begin
            // Get Frame
            Ok := False;

			CxGetScreenParams(H,Params);
			Params.Width := 1280;
			Params.Height := 1024;
			Params.StartX := 0;
			Params.StartY := 0;
			Params.Decimation := 1;
			CxSetScreenParams(H,Params);

            SnapshotThreadParams.hEvent := CreateEvent(nil,True,False,PChar('SMXSnapshot'+IntToStr(CameraNo)) );
            SnapshotThreadParams.H := H;
            SnapshotThreadParams.Timeout := spnTimeout.Value;
            SnapshotThreadParams.ExtTrgEnabled := cbExtTrgEnabled.Checked;
            SnapshotThreadParams.ExtTrgPolarity := rbPositive.Checked;
            SnapshotThreadParams.SnapshotMode := True;
            SnapshotThreadParams.Buffer := @SnapshotFrame;
            SnapshotThreadParams.BufSize := sizeof(SnapshotFrame);
            hThread := CreateThread(Nil,0,@GetSnapshotThreadProc,@SnapshotThreadParams,CREATE_SUSPENDED,ThreadId);

            if hThread <> 0 then begin
                SetThreadPriority(hThread,THREAD_PRIORITY_IDLE);
                ResumeThread(hThread);

                btSnapshot.Enabled := False;
                btCancelSnapshot.Enabled := True;

                while True do begin
                    if SnapshotThreadParams.hEvent<>0 then begin
                        State := WaitForSingleObject( SnapshotThreadParams.hEvent, 200 );
                        if (State = WAIT_OBJECT_0) then break;
                    end else
                        break;
                    Application.ProcessMessages;
                end;

                if SnapshotThreadParams.hEvent<>0 then begin
                    CloseHandle(SnapshotThreadParams.hEvent);
                end;

                btCancelSnapshot.Enabled := False;
                btSnapshot.Enabled := True;

                TerminateThread(hThread,0);
                CloseHandle(hThread);

                if not SnapshotThreadParams.Status then begin
                    DisplayMessage( 'Snapshot Status: Error!')
                end else begin
                    Ok := False;
                    if SnapshotThreadParams.RetLen = 0 then
                        DisplayMessage( 'Snapshot Status: Empty Frame (Timeout ?)!')
                    else
                        Ok := True;
                end;

            end;

            // Show snapshot
            if Ok then begin
                CxGetScreenParams(H,Params);
                Params.Width := Params.Width div Params.Decimation;
                Params.Height := Params.Height div Params.Decimation;
                SSForm.ShowFrame( @SnapshotFrame, Params.Width, Params.Height, Params.ColorDeep );
                FName := IntToStr(FSnapshotCounter) + '.BMP';
                SaveAsBitmap( FName, @SnapshotFrame, Params.Width , Params.Height, Params.ColorDeep);
                Inc(FSnapshotCounter);
                DisplayMessage( 'Snapshot Saved !');
            end else begin
                SSForm.Hide;
            end;
            // Close device
            CxCloseDevice(H);
        end else begin
            DisplayMessage('Error open Camera #0!');
        end;
    except
    // leave default setting
    end;
End;


procedure TForm1.btCancelSnapshotClick(Sender: TObject);
Var
    H : THandle;
begin
    try
        // Open device
        H := CxOpenDevice(CameraNo);
        if H <> INVALID_HANDLE_VALUE then begin
            CxCancelSnapshot(H);
            CxCloseDevice(H);
         end;
    except
    // leave default setting
    end;
end;

procedure TForm1.ComboBox1Change(Sender: TObject);
begin
    CameraNo := ComboBox1.ItemIndex;
end;

End.

