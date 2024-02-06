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
    function GetDateInfo: string;
  protected
    procedure doRun; override;
  end;

const
  WEBSITE_TITLE = 'kveroneau.github.io';
  DATE_FORMAT = 'dddd mmmm d, yyyy "at" hh:nn';

function markdown(const s: string): string; external name 'window.marked.parse';

procedure TMyHomePage.HandleRoute(URL: String; aRoute: TRoute; Params: TStrings
  );
var
  buf: string;
begin
  FDatabase.Filter:='Path='+QuotedStr(URL);
  if FDatabase.DataSet.EOF then
  begin
    GetHTMLElement('title').innerHTML:=WEBSITE_TITLE;
    document.title:='Resource not found';
    GetHTMLElement('modified').innerHTML:='An error has occured.';
    GetHTMLElement('content').innerHTML:='<h1>Resource not found.</h1>';
    Exit;
  end;
  GetHTMLElement('title').innerHTML:=FDatabase.Strings['Title'];
  if FDatabase.Strings['Title'] <> WEBSITE_TITLE then
    document.title:=FDatabase.Strings['Title']+' :: '+WEBSITE_TITLE;
  GetHTMLElement('modified').innerHTML:=GetDateInfo;
  case FDatabase.Ints['ContentType'] of
    0: buf:=FDatabase.Strings['Content']; // HTML Content
    1: buf:=markdown(FDatabase.Strings['Content']); // Markdown Content
  else
    buf:='<b>Unknown Content-Type!</b>';
  end;
  GetHTMLElement('content').innerHTML:=buf;
end;

function TMyHomePage.GetDateInfo: string;
var
  ddiff: TDateTime;
begin
  Result:='<b>Created on</b> '+FormatDateTime(DATE_FORMAT, FDatabase.Dates['Created']);
  ddiff:=FDatabase.Dates['Modified']-FDatabase.Dates['Created'];
  if ddiff >= 1.0 then
    Result:=Result+'<br/><b>Last Updated on</b> '+FormatDateTime(DATE_FORMAT, FDatabase.Dates['Modified']);
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

