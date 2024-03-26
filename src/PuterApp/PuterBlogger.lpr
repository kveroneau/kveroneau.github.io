program PuterBlogger;

{$mode objfpc}

uses
  browserapp, JS, Classes, SysUtils, Web, widgets, puterjs, bulma, p2jsres,
  PuterHosting, PuterDB, BlogEditor, Rtl.BrowserLoadHelper, BlogList;

type

  { TPuterBlogApp }

  TPuterBlogApp = class(TBrowserApplication)
  private
    FName: TJSHTMLInputElement;
    FTitle: TBulmaInput;
    function ButtonClick(aEvent: TJSMouseEvent): boolean;
  protected
    procedure doRun; override;
  end;

{ TPuterBlogApp }

function TPuterBlogApp.ButtonClick(aEvent: TJSMouseEvent): boolean;
begin
  document.write(FName.value);
end;

procedure TPuterBlogApp.doRun;
begin
  Puter.WindowTitle:='Puter Blogger at your service';
  TabBody.setContent('Checking website information, please wait...');
  InitTypesDB;
  PuterSites:=TPuterHosting.Create(Self);
  PuterSites.CheckSites;
  BlogEditorForm:=TBlogEditorForm.Create(Self);
  if False then
    BlogEditorForm.GotoRecord('');
  DBGrid:=TBlogList.Create(Self);
end;

var
  Application : TPuterBlogApp;

begin
  Application:=TPuterBlogApp.Create(nil);
  Application.Initialize;
  Application.Run;
end.
