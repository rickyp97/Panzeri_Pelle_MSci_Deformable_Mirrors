unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, SMXM7X;
//  Dialogs, CamsxApi;

type
  TViewForm = class(TForm)
    procedure FormActivate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  ViewForm: TViewForm;

implementation

{$R *.dfm}

procedure TViewForm.FormActivate(Sender: TObject);
begin
    CxSetBayerAlg(2);
    CxStartVideo( Self.Handle,0);
end;

procedure TViewForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
    CxStopVideo(0);
end;

end.
