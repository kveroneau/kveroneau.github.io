unit PuterHosting;

{$mode ObjFPC}

interface

uses
  Classes, SysUtils, puterjs, widgets, bulma, Web, p2jsres, Types, strutils,
  PuterDB, jsontable, BlogEditor;

type

  { TPuterHosting }

  TPuterHosting = Class(TComponent)
  private
    FSubdomain: TBulmaInput;
    FInst: string;
    function ListSuccess(AValue: JSValue): JSValue;
    function HostSuccess(AValue: JSValue): JSValue;
    function DelSuccess(AValue: JSValue): JSValue;
    procedure AddNewSite;
    procedure ListSites(SiteList: TPuterHostList);
    function GetResource(AName: string): string;
    function CreateSite(aEvent: TJSMouseEvent): boolean;
    procedure PuterError(AError: TPuterErrorMsg);
    procedure InstallBlog(ADir: TPuterFSItem);
    procedure InstallFile(ARscr, AFile: string);
    procedure InstallPyapi(ADir: TPuterFSItem);
    function DeleteSite(aEvent: TJSMouseEvent): boolean;
    function EditSite(aEvent: TJSMouseEvent): boolean;
    procedure DatabaseLoaded(AContent: string);
  public
    property Subdomain: string read FInst;
    procedure CheckSites;
    procedure SaveDatabase;
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
  if Length(sites) = 0 then
    AddNewSite
  else
    ListSites(sites);
end;

function TPuterHosting.HostSuccess(AValue: JSValue): JSValue;
var
  info: TResourceInfo;
begin
  if not GetResourceInfo(rsHTML, 'initdb', info) then
    raise Exception.Create('Resource missing: initdb');
  Puter.WriteFile(FInst+'/website.json', window.atob(info.data));
  TabBody.setContent('Hosting success: <a href="https://'+FInst+'.puter.site/">Visit</a>!');
end;

function TPuterHosting.DelSuccess(AValue: JSValue): JSValue;
begin
  TabBody.setContent('Site Deleted.<br/>');
  CheckSites;
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
  btn: TBulmaButton;
begin
  for i:=0 to Length(SiteList)-1 do
  begin
    TabBody.Write('<a href="https://'+SiteList[i].subdomain+'.puter.site/">'+SiteList[i].subdomain+'</a>');
    btn:=TBulmaButton.Create(Self, 'Delete', 'del-'+SiteList[i].subdomain, @DeleteSite);
    TabBody.Write(btn.renderHTML);
    btn.Bind;
    btn:=TBulmaButton.Create(Self, 'Edit', 'edit-'+SiteList[i].subdomain, @EditSite);
    TabBody.Write(btn.renderHTML+'<br/>');
    btn.Bind;
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

function TPuterHosting.DeleteSite(aEvent: TJSMouseEvent): boolean;
var
  id,site: string;
begin
  site:=aEvent.targetElement.id;
  id:=Copy2SymbDel(site, '-');
  TabBody.setContent('Site: '+site);
  PuterAPI.hosting.delete(site)._then(@DelSuccess);
end;

function TPuterHosting.EditSite(aEvent: TJSMouseEvent): boolean;
var
  id, site: string;
begin
  site:=aEvent.targetElement.id;
  id:=Copy2SymbDel(site, '-');
  FInst:=site;
  TabBody.setContent('Loading Database...');
  BlogDB:=TJSONTable.Create(Self);
  Puter.OnReadSuccess:=@DatabaseLoaded;
  Puter.ReadFile(site+'/website.json');
end;

procedure TPuterHosting.DatabaseLoaded(AContent: string);
begin
  BlogDB.ParseTable(AContent);
  BlogEditorForm.Subdomain:=FInst;
  BlogEditorForm.Show;
end;

procedure TPuterHosting.CheckSites;
begin
  PuterAPI.hosting.list._then(@ListSuccess);
end;

procedure TPuterHosting.SaveDatabase;
begin
  Puter.WriteFile(FInst+'/website.json', BlogDB.GetJSON);
end;

end.

