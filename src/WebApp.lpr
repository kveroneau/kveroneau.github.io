program WebApp;

{$mode objfpc}
{$modeswitch externalclass}

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
    function CodeHighlight(lang, content: string): string;
    function RenderContent(ct: Integer): string;
    procedure HandleRequest;
    {$IFNDEF EMBEDSITE}
    procedure TableLoadError;
    {$ENDIF}
  protected
    procedure doRun; override;
  public
    function GetContent(APath: string): string;
    procedure AfterInit(RealRun: Boolean);
  end;

const
  WEBSITE_TITLE = 'kveroneau.github.io';
  DATE_FORMAT = 'dddd mmmm d, yyyy "at" hh:nn';

function markdown(const s: string): string; external name 'window.marked.parse';
procedure initHighlight; external name 'window.hljs.initHighlighting';
procedure RunJS(s: string); external name 'window.eval';
procedure RunPy(options: TJSObject); external name 'window.brython';

procedure TMyHomePage.HandleRoute(URL: String; aRoute: TRoute; Params: TStrings
  );
var
  buf: string;
  ct: integer;
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
  ct:=FDatabase.Ints['ContentType'];
  GetHTMLElement('content').innerHTML:=RenderContent(ct);
  if (ct > 99) and (ct < 200) then
    initHighlight
  else if ct = 50 then
    RunJS(FDatabase.Strings['Content'])
  else if ct = 51 then
    RunJS('window.brython({pythonpath:[''/pyapi'']});');
  //RunPy(TJSObject.new);
end;

function TMyHomePage.GetDateInfo: string;
var
  ddiff: TDateTime;
begin
  Result:=FormatDateTime(DATE_FORMAT, FDatabase.Dates['Created']);
  ddiff:=FDatabase.Dates['Modified']-FDatabase.Dates['Created'];
  if ddiff >= 1.0 then
    Result:='<b>Created on</b> '+Result+'<br/><b>Last Updated on</b> '+FormatDateTime(DATE_FORMAT, FDatabase.Dates['Modified']);
end;

function TMyHomePage.CodeHighlight(lang, content: string): string;
begin
  Result:='<pre><code class="language-'+lang+'">'+content+'</code></pre>';
end;

function TMyHomePage.RenderContent(ct: Integer): string;
begin
  case ct of
    0: Result:=FDatabase.Strings['Content']; // HTML Content
    1: Result:=markdown(FDatabase.Strings['Content']); // Markdown Content
    50: Result:='Loading JavaScript Application, please wait...';
    51: Result:='<script type="text/python">'+FDatabase.Strings['Content']+'</script>';
    100: Result:=CodeHighlight('pascal',FDatabase.Strings['Content']);
    101: Result:=CodeHighlight('bash',FDatabase.Strings['Content']);
    102: Result:=CodeHighlight('python',FDatabase.Strings['Content']);
    103: Result:=CodeHighlight('ruby',FDatabase.Strings['Content']);
    104: Result:=CodeHighlight('c',FDatabase.Strings['Content']);
    105: Result:=CodeHighlight('makefile',FDatabase.Strings['Content']);
    106: Result:=CodeHighlight('javascript',FDatabase.Strings['Content']);
  else
    Result:='<b>Unknown Content-Type!</b>';
  end;
end;

procedure TMyHomePage.HandleRequest;
begin
  GetContent('/NaR'); // This triggers the compiler to compile this method.
  Router.InitHistory(hkHash);
  Router.RegisterRoute('*', @HandleRoute);
  AfterInit(False); // Registers method with compiler for export in JavaScript.
end;

{$IFNDEF EMBEDSITE}
procedure TMyHomePage.TableLoadError;
begin
  document.getElementById('title').innerHTML:='Framework Error!';
  document.getElementById('content').innerHTML:='The Framework was unable to locate and open it''s database file.';
  Terminate(2);
end;
{$ENDIF}

procedure TMyHomePage.doRun;
begin
  { This web app so far is just the initial set-up of what's to come.
    Namely making it easy to use JSONDatasets which can be generated from
    an application. }
  FDatabase:=TWebsiteDB.Create(Self);
  {$IFNDEF EMBEDSITE}
  FDatabase.OnSuccess:=@HandleRequest;
  FDatabase.OnFailure:=@TableLoadError;
  FDatabase.Active:=True;
  {$ELSE}
  HandleRequest;
  {$ENDIF}
end;

function TMyHomePage.GetContent(APath: string): string;
begin
  FDatabase.Filter:='Path='+QuotedStr(APath);
  if FDatabase.DataSet.EOF then
    Result:=''
  else
    Result:=RenderContent(FDatabase.Ints['ContentType']);
end;

procedure TMyHomePage.AfterInit(RealRun: Boolean);
begin
  if {$IFDEF EMBEDSITE}not{$ENDIF}RealRun then
    Exit;
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

