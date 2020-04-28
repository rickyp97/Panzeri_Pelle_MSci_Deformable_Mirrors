unit
    AllocMemory;

interface

uses
    Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
    Dialogs, Math, StdCtrls, ActiveX, ComCtrls;


function AllocFrames( FrameSize:Integer; Var FramesPtr:PChar; Var FrameNum:Integer ) : Boolean;
function FreeFrames ( FrameSize:Integer;     FramesPtr:PChar;     FrameNum:Integer ) : Boolean;


implementation ///////////////////////////////////////////////////////


Type
    MEMORYSTATUSEX = packed record
                dwLength : DWORD;
                dwMemoryLoad : DWORD;
                ullTotalPhys : Int64;
                ullAvailPhys : Int64;  
                ullTotalPageFile : Int64;
                ullAvailPageFile : Int64;
                ullTotalVirtual : Int64;
                ullAvailVirtual : Int64;
                ullAvailExtendedVirtual : Int64;
            end;

Function GlobalMemoryStatusEx(Var Buf:MEMORYSTATUSEX) : boolean; stdcall; external 'Kernel32.dll';

function AllocFrames( FrameSize:Integer; Var FramesPtr:PChar; Var FrameNum:Integer ) : Boolean;
Var
    hProcess : THandle;
    statex : MEMORYSTATUSEX;
Begin
    Result := False;
    
    FramesPtr := nil;
    FrameNum := 0;
    hProcess := GetCurrentProcess();

// WRITELN('1');

    statex.dwLength := sizeof( statex );
    if not GlobalMemoryStatusEx( statex ) then
        Exit;

// WRITELN('2');

    FrameNum := statex.ullAvailPhys div FrameSize;

// WRITELN('3');

    while (FrameNum > 0) and (not SetProcessWorkingSetSize(hProcess,FrameNum*FrameSize,FrameNum*FrameSize) ) do
        Dec(FrameNum);

// WRITELN('4');

    if FrameNum <= 0 then
        Exit;

// WRITELN('5');

    while FrameNum>0 do begin
        FramesPtr := VirtualAlloc( nil, FrameNum*FrameSize, MEM_COMMIT, PAGE_READWRITE );
        if FramesPtr=nil then begin
            Dec(FrameNum);
        end else begin
            if VirtualLock( FramesPtr, FrameNum*FrameSize ) then begin
                break;
            end else begin
                Dec(FrameNum);
                VirtualFree( FramesPtr, 0, MEM_RELEASE);
            end;
        end;
    end;

// WRITELN('6');

    Result := True;
End;


function FreeFrames( FrameSize:Integer;     FramesPtr:PChar;     FrameNum:Integer ) : Boolean;
Begin
    Result := False;

    if FramesPtr=nil then
        Exit;

    VirtualUnlock( FramesPtr, FrameSize * FrameNum );

    Result := VirtualFree( FramesPtr, 0, MEM_RELEASE );
End;

End.
