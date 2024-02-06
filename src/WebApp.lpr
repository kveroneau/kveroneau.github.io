program WebApp;

{$mode objfpc}

uses
  browserconsole, browserapp, JS, Classes, SysUtils, Web, models, DateUtils,
  webrouter;

type

  { TMyHomePage }

  TMyHomePage = class(TBrowserApplication)
  private
    FDatabase: TWebsiteDB;
    Procedure HandleRoute(URL: String; aRoute: TRoute; Params: TStrings);
  protected
    procedure doRun; override;
  end;

function markdown(const s: string): string; external name 'window.marked.parse';

procedure TMyHomePage.HandleRoute(URL: String; aRoute: TRoute; Params: TStrings
  );
var
  buf: string;
begin
  FDatabase.Filter:='Path='+QuotedStr(URL);
  if FDatabase.DataSet.EOF then
  begin
    GetHTMLElement('title').innerHTML:='kveroneau.github.io';
    GetHTMLElement('modified').innerHTML:='An error has occured.';
    GetHTMLElement('content').innerHTML:='<h1>Resource not found.</h1>';
    Exit;
  end;
  GetHTMLElement('title').innerHTML:=FDatabase.Strings['Title'];
  GetHTMLElement('modified').innerHTML:=FormatDateTime('dddd mmmm d, yyyy "at" hh:nn', FDatabase.Dates['Created']);
  case FDatabase.Ints['ContentType'] of
    0: buf:=FDatabase.Strings['Content']; // HTML Content
    1: buf:=markdown(FDatabase.Strings['Content']); // Markdown Content
  else
    buf:='<b>Unknown Content-Type!</b>';
  end;
  GetHTMLElement('content').innerHTML:=buf;
end;

procedure TMyHomePage.doRun;
begin
  { This web app so far is just the initial set-up of what's to come.
    Namely making it easy to use JSONDatasets which can be generated from
    an application. }
  FDatabase:=TWebsiteDB.Create(Self);
  Router.InitHistory(hkHash);
  Router.RegisterRoute('*', @HandleRoute);
  if Router.RouteFromURL = '' then
    Router.Push('/index');
end;

var
  Application : TMyHomePage;

begin
  Application:=TMyHomePage.Create(nil);
  Application.Initialize;
  Application.Run;
end.

