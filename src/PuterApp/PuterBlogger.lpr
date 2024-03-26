program PuterBlogger;

{$mode objfpc}

uses
  browserapp, JS, Classes, SysUtils, Web, widgets, puterjs, bulma, p2jsres,
  PuterHosting, PuterDB, BlogEditor, Rtl.BrowserLoadHelper;

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
  PuterSites:=TPuterHosting.Create(Self);
  PuterSites.CheckSites;
  BlogEditorForm:=TBlogEditorForm.Create(Self);
  {FTitle:=TBulmaInput.Create(Self, 'A Title:', 'title');
  TabBody.Write(FTitle.renderHTML);
  FName:=MakeInputField('name', 'Your Name', 'Some Name');
  MakeButton('test2', 'Another Button', @ButtonClick);}
end;

var
  Application : TPuterBlogApp;

begin
  Application:=TPuterBlogApp.Create(nil);
  Application.Initialize;
  Application.Run;
end.
