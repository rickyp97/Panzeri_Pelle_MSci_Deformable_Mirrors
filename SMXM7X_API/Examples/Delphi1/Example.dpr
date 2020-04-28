program Example;

uses
  Forms,
  Unit1 in 'Unit1.pas' {ViewForm},
  SMXM7X in 'SMXM7X.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TViewForm, ViewForm);
  Application.Run;
end.
