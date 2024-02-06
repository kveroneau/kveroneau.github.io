program DBAdmin;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}
  cthreads,
  {$ENDIF}
  {$IFDEF HASAMIGA}
  athreads,
  {$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, lazdbexport, DBAdminWindow
  { you can add units after this };

{$R *.res}

begin
  RequireDerivedFormResource:=True;
  Application.Title:='kveroneau.github.io Admin App';
  Application.Scaled:=True;
  Application.Initialize;
  Application.CreateForm(TDBAdminForm, DBAdminForm);
  Application.Run;
end.

