program WebApp;

{$mode objfpc}

uses
  browserconsole, browserapp, JS, Classes, SysUtils, Web, models;

type
  TMyHomePage = class(TBrowserApplication)
  private
    FDatabase: TCustomerDB;
  protected
    procedure doRun; override;
  end;

procedure TMyHomePage.doRun;

begin
  Writeln('Hello World from ObjectPascal!');
  FDatabase:=TCustomerDB.Create(Self);
  {FDatabase.Filter:='PHONE='+QuotedStr('2042311685');}
  repeat
    Writeln(FDatabase.Name);
    FDatabase.DataSet.Next;
  until FDatabase.DataSet.EOF;
end;

var
  Application : TMyHomePage;

begin
  Application:=TMyHomePage.Create(nil);
  Application.Initialize;
  Application.Run;
end.

