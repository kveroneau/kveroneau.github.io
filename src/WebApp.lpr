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
  { This web app so far is just the initial set-up of what's to come.
    Namely making it easy to use JSONDatasets which can be generated from
    an application. }
  Writeln('Hello World from ObjectPascal!');
  FDatabase:=TCustomerDB.Create(Self);
  {FDatabase.Filter:='PHONE='+QuotedStr('5552220505');}
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

