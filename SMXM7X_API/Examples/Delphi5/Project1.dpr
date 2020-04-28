program Project1;

uses
  Forms,
  Unit1 in 'Unit1.pas' {Form1},
  Unit2 in 'Unit2.pas' {SSForm},
  SMXM7X in 'SMXM7X.pas',
  AllocMemory in 'AllocMemory.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.CreateForm(TSSForm, SSForm);
  Application.Run;
end.
