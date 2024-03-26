unit PuterHosting;

{$mode ObjFPC}

interface

uses
  Classes, SysUtils, puterjs, widgets, bulma, Web, p2jsres, Types;

type

  { TPuterHosting }

  TPuterHosting = Class(TComponent)
  private
    FSubdomain: TBulmaInput;
    FInst: string;
    function ListSuccess(AValue: JSValue): JSValue;
    function HostSuccess(AValue: JSValue): JSValue;
    procedure AddNewSite;
    procedure ListSites(SiteList: TPuterHostList);
    function GetResource(AName: string): string;
    function CreateSite(aEvent: TJSMouseEvent): boolean;
    procedure PuterError(AError: TPuterErrorMsg);
    procedure InstallBlog(ADir: TPuterFSItem);
    procedure InstallFile(ARscr, AFile: string);
    procedure InstallPyapi(ADir: TPuterFSItem);
  public
    procedure CheckSites;
  end;

var
  PuterSites: TPuterHosting;

implementation

{ TPuterHosting }

function TPuterHosting.ListSuccess(AValue: JSValue): JSValue;
var
  sites: TPuterHostList;
begin
  sites:=TPuterHostList(AValue);
  TabBody.setContent('You have '+IntToStr(Length(sites))+' websites.<br/>');
  if Length(sites) = 1 then
    AddNewSite
  else
    ListSites(sites);
end;

function TPuterHosting.HostSuccess(AValue: JSValue): JSValue;
begin
  TabBody.setContent('Hosting success: <a href="https://'+FInst+'.puter.site/">Visit</a>!');
end;

procedure TPuterHosting.AddNewSite;
var
  btn: TBulmaButton;
begin
  LoadHTMLLinkResources('PuterBlogger-res.html');
  with TabBody do
  begin
    Write('<h4>Create new Blog</h4><br/>');
    FSubdomain:=TBulmaInput.Create(Self, 'Subdomain', 'subdomain');
    Write(FSubdomain.renderHTML);
    btn:=TBulmaButton.Create(Self, 'Create Site', 'createBtn', @CreateSite);
    Write(btn.renderHTML);
    FSubdomain.Value:=PuterAPI.randName;
    btn.Bind;
  end;
end;

procedure TPuterHosting.ListSites(SiteList: TPuterHostList);
var
  i: integer;
begin
  for i:=0 to Length(SiteList)-1 do
  begin
    TabBody.Write('<a href="https://'+SiteList[i].subdomain+'.puter.site/">'+SiteList[i].subdomain+'</a><br/>');
  end;
end;

function TPuterHosting.GetResource(AName: string): string;
var
  info: TResourceInfo;
begin
  if not GetResourceInfo(rsHTML, AName, info) then
    raise Exception.Create('Missing Resource: '+AName);
  Result:=window.atob(info.data);
end;

function TPuterHosting.CreateSite(aEvent: TJSMouseEvent): boolean;
begin
  FInst:=FSubdomain.Value;
  with TabBody do
  begin
    setContent('Installing blogging software into website...<br/>');
    Puter.OnPuterError:=@PuterError;
    Puter.OnDirSuccess:=@InstallBlog;
    Puter.MakeDirectory(FInst);
  end;
end;

procedure TPuterHosting.PuterError(AError: TPuterErrorMsg);
begin
  TabBody.setContent('There was an error: '+AError.message);
end;

procedure TPuterHosting.InstallBlog(ADir: TPuterFSItem);
begin
  TabBody.Write('Website directory created.<br/>');
  InstallFile('index', 'index.html');
  InstallFile('webapp', 'WebApp.js');
  InstallFile('api', 'api.js');
  Puter.OnDirSuccess:=@InstallPyapi;
  Puter.MakeDirectory(FInst+'/pyapi');
end;

procedure TPuterHosting.InstallFile(ARscr, AFile: string);
var
  data: string;
begin
  data:=GetResource(ARscr);
  Puter.WriteFile(FInst+'/'+AFile, data);
  TabBody.Write('Installed '+AFile+'.<br/>');
end;

procedure TPuterHosting.InstallPyapi(ADir: TPuterFSItem);
begin
  InstallFile('website', 'pyapi/website.py');
  PuterAPI.hosting.create(FInst, FInst)._then(@HostSuccess);
end;

procedure TPuterHosting.CheckSites;
begin
  PuterAPI.hosting.list._then(@ListSuccess);
end;

end.

