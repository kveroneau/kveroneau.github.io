program PuterBlogger;

{$mode objfpc}

uses
  browserapp, JS, Classes, SysUtils, Web, widgets, puterjs, bulma, p2jsres,
  PuterHosting, PuterDB, BlogEditor, Rtl.BrowserLoadHelper, BlogList;

type

  { TPuterBlogApp }

  TPuterBlogApp = class(TBrowserApplication)
  protected
    procedure doRun; override;
  end;

{ TPuterBlogApp }

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
