program PuterBlogger;

{$mode objfpc}

uses
  browserapp, JS, Classes, SysUtils, Web, widgets, puterjs;

type

  { TPuterBlogApp }

  TPuterBlogApp = class(TBrowserApplication)
  private
    FName: TJSHTMLInputElement;
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
  FName:=MakeInputField('name', 'Your Name:', 'Some Name');
  MakeButton('test2', 'Another Button', @ButtonClick);
end;

var
  Application : TPuterBlogApp;

begin
  Application:=TPuterBlogApp.Create(nil);
  Application.Initialize;
  Application.Run;
end.
