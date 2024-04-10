unit PuterHosting;

{$mode ObjFPC}

interface

uses
  Classes, SysUtils, puterjs, widgets, bulma, Web, p2jsres, Types, strutils,
  PuterDB, jsontable, BlogEditor, BlogList, JS;

type

  TSiteSettings = class(TJSObject)
  public
    title: string;
  end;

  { TResourceLoader }

  TResourceLoader = class(TComponent)
  private
    FData: TStringList;
    FTarget: string;
    procedure DataLoaded(Sender: TObject);
  public
    constructor Create(AOwner: TComponent; AName, ATarget: string);
  end;

  TModeType = (mtNewSite, mtUpdateSite);

  { TPuterHosting }

  TPuterHosting = Class(TComponent)
  private
    FSubdomain, FSiteTitle: TBulmaInput;
    FInst, FSiteTitleS: string;
    FInstMode: TModeType;
    procedure ShowSuccess(AMessage: string);
    function ListSuccess(AValue: JSValue): JSValue;
    function HostSuccess(AValue: JSValue): JSValue;
    function DelSuccess(AValue: JSValue): JSValue;
    procedure InstallSite;
    procedure AddNewSite;
    procedure ListSites(SiteList: TPuterHostList);
    {$IFDEF INSTEMBED}
    function GetResource(AName: string): string;
    {$ENDIF}
    function CreateSite(aEvent: TJSMouseEvent): boolean;
    procedure PuterError(AError: TPuterErrorMsg);
    procedure DeployApple2(AError: TPuterErrorMsg);
    procedure InstallBlog(ADir: TPuterFSItem);
    procedure InstallFile(ARscr, AFile: string);
    procedure InstallPyapi(ADir: TPuterFSItem);
    procedure InstallApple2(ADir: TPuterFSItem);
    procedure InstallApple2Res(ADir: TPuterFSItem);
    procedure UpdateApple2(ADirList: TPuterDirList);
    function DeleteSite(aEvent: TJSMouseEvent): boolean;
    function EditSite(aEvent: TJSMouseEvent): boolean;
    procedure DatabaseLoaded(AContent: string);
    procedure ExportDS(AContent: string);
    function ExportData(aEvent: TJSMouseEvent): boolean;
    procedure ImportFile(AFile: TPuterFSItem);
    function ImportData(aEvent: TJSMouseEvent): boolean;
    function AddSiteClick(aEvent: TJSMouseEvent): boolean;
    procedure UpdateSite(ASite: string);
    function SiteAction(aEvent: TJSMouseEvent): boolean;
    function SiteSettings(aEvent: TJSMouseEvent): boolean;
    procedure SettingsLoaded(AContent: string);
    function SaveSettings(aEvent: TJSMouseEvent): boolean;
  public
    property Subdomain: string read FInst;
    procedure CheckSites;
    procedure SaveDatabase;
  end;

var
  PuterSites: TPuterHosting;

implementation

{ TResourceLoader }

procedure TResourceLoader.DataLoaded(Sender: TObject);
begin
  Puter.WriteFile(FTarget, FData.Text);
  FData.Free;
end;

constructor TResourceLoader.Create(AOwner: TComponent; AName, ATarget: string);
begin
  inherited Create(AOwner);
  FTarget:=ATarget;
  FData:=TStringList.Create;
  FData.LoadFromURL('Bundle/'+AName+'.res', True, @DataLoaded);
end;

{$IFDEF INSTEMBED}
{$R ../WebApp.js}
{$R ../index.html}
{$R ../api.js}
{$R ../../pyapi/website.py}
{$ENDIF}

{ TPuterHosting }

procedure TPuterHosting.ShowSuccess(AMessage: string);
var
  btn: TBulmaButton;
begin
  TabBody.setContent(AMessage+': <a href="https://'+FInst+'.puter.site/" target="_new">Visit</a>!<br/>');
  btn:=TBulmaButton.Create(Self, 'Edit', 'edit-'+FInst, @EditSite);
  TabBody.Write(btn.renderHTML);
  btn.Bind;
end;

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
  Puter.WriteFile(FInst+'/settings.json', '{"title":"Puter Blog"}');
  ShowSuccess('Host success');
end;

function TPuterHosting.DelSuccess(AValue: JSValue): JSValue;
begin
  TabBody.setContent('Site Deleted.<br/>');
  CheckSites;
end;

procedure TPuterHosting.InstallSite;
begin
  InstallFile('index', 'index.html');
  InstallFile('webapp', 'WebApp.js');
  InstallFile('api', 'api.js');
end;

procedure TPuterHosting.AddNewSite;
var
  btn: TBulmaButton;
begin
  FInstMode:=mtNewSite;
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
  DelBtn: Array[0..31] of TBulmaButton;
  EdtBtn: Array[0..31] of TBulmaButton;
  ImpBtn: Array[0..31] of TBulmaButton;
  ExpBtn: Array[0..31] of TBulmaButton;
  UpdBtn: Array[0..31] of TBulmaButton;
begin
  btn:=TBulmaButton.Create(Self, 'Add Blog', 'addBtn', @AddSiteClick);
  TabBody.setContent(btn.renderHTML+'<br/>');
  for i:=0 to Length(SiteList)-1 do
  begin
    TabBody.Write('<a href="https://'+SiteList[i].subdomain+'.puter.site/"  target="_new">'+SiteList[i].subdomain+'</a>');
    DelBtn[i]:=TBulmaButton.Create(Self, 'Delete', 'del-'+SiteList[i].subdomain, @DeleteSite);
    TabBody.Write(DelBtn[i].renderHTML);
    EdtBtn[i]:=TBulmaButton.Create(Self, 'Edit', 'edit-'+SiteList[i].subdomain, @EditSite);
    TabBody.Write(EdtBtn[i].renderHTML);
    ExpBtn[i]:=TBulmaButton.Create(Self, 'Export', 'exp-'+SiteList[i].subdomain, @ExportData);
    TabBody.Write(ExpBtn[i].renderHTML);
    ImpBtn[i]:=TBulmaButton.Create(Self, 'Import', 'imp-'+SiteList[i].subdomain, @ImportData);
    TabBody.Write(ImpBtn[i].renderHTML);
    UpdBtn[i]:=TBulmaButton.Create(Self, 'Update', 'upd-'+SiteList[i].subdomain, @SiteAction);
    TabBody.Write(UpdBtn[i].renderHTML+'<br/>');
  end;
  btn.Bind;
  for i:=0 to Length(SiteList)-1 do
  begin
    DelBtn[i].Bind;
    EdtBtn[i].Bind;
    ExpBtn[i].Bind;
    ImpBtn[i].Bind;
    UpdBtn[i].Bind;
  end;
end;

{$IFDEF INSTEMBED}
function TPuterHosting.GetResource(AName: string): string;
var
  info: TResourceInfo;
begin
  if not GetResourceInfo(rsHTML, AName, info) then
    raise Exception.Create('Missing Resource: '+AName);
  Result:=window.atob(info.data);
end;
{$ENDIF}

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

procedure TPuterHosting.DeployApple2(AError: TPuterErrorMsg);
begin
  TabBody.Write('No apple2 installation detected, installing...');
  Puter.OnPuterError:=@PuterError;
  Puter.OnDirSuccess:=@InstallApple2;
  Puter.MakeDirectory(FInst+'/apple2');
end;

procedure TPuterHosting.InstallBlog(ADir: TPuterFSItem);
begin
  TabBody.Write('Website directory created.<br/>');
  InstallSite;
  Puter.OnDirSuccess:=@InstallPyapi;
  Puter.MakeDirectory(FInst+'/pyapi');
end;

procedure TPuterHosting.InstallFile(ARscr, AFile: string);
var
{$IFDEF INSTEMBED}
  data: string;
{$ELSE}
  Res: TResourceLoader;
{$ENDIF}
begin
  {$IFDEF INSTEMBED}
  data:=GetResource(ARscr);
  Puter.WriteFile(FInst+'/'+AFile, data);
  {$ELSE}
  Res:=TResourceLoader.Create(Self, ARscr, FInst+'/'+AFile);
  {$ENDIF}
  TabBody.Write('Installed '+AFile+'.<br/>');
end;

procedure TPuterHosting.InstallPyapi(ADir: TPuterFSItem);
begin
  InstallFile('website', 'pyapi/website.py');
  Puter.OnDirSuccess:=@InstallApple2;
  Puter.MakeDirectory(FInst+'/apple2');
end;

procedure TPuterHosting.InstallApple2(ADir: TPuterFSItem);
begin
  InstallFile('apple2/script', 'apple2/script.js');
  InstallFile('apple2/tty', 'apple2/tty.js');
  InstallFile('apple2/lores', 'apple2/lores.js');
  InstallFile('apple2/hires', 'apple2/hires.js');
  InstallFile('apple2/bell', 'apple2/bell.js');
  InstallFile('apple2/dos', 'apple2/dos.js');
  InstallFile('apple2/basic', 'apple2/basic.js');
  InstallFile('apple2/display', 'apple2/display.css');
  Puter.OnDirSuccess:=@InstallApple2Res;
  Puter.MakeDirectory(FInst+'/apple2/res');
end;

procedure TPuterHosting.InstallApple2Res(ADir: TPuterFSItem);
begin
  InstallFile('apple2/font-40col', 'apple2/res/font-40col.png');
  InstallFile('apple2/font-80col', 'apple2/res/font-80col.png');
  if FInstMode = mtNewSite then
    PuterAPI.hosting.create(FInst, FInst)._then(@HostSuccess)
  else if FInstMode = mtUpdateSite then
    ShowSuccess('Update Success');
end;

procedure TPuterHosting.UpdateApple2(ADirList: TPuterDirList);
begin
  InstallApple2(Nil);
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
  DBGrid.Subdomain:=FInst;
  BlogEditorForm.Show;
  SettingsTab:=TabSys.AddTab('Settings', 'SettingsTab', @SiteSettings);
  TabSys.renderHTML;
  Puter.OnReadSuccess:=@SettingsLoaded;
  Puter.ReadFile(FInst+'/settings.json');
end;

procedure TPuterHosting.ExportDS(AContent: string);
begin
  puter.SaveFileDialog(AContent);
end;

function TPuterHosting.ExportData(aEvent: TJSMouseEvent): boolean;
var
  id, site: string;
begin
  site:=aEvent.targetElement.id;
  id:=Copy2SymbDel(site, '-');
  Puter.OnReadSuccess:=@ExportDS;
  puter.ReadFile(site+'/website.json');
end;

procedure TPuterHosting.ImportFile(AFile: TPuterFSItem);
begin
  Puter.WriteFile(FInst+'/website.json', AFile.content);
end;

function TPuterHosting.ImportData(aEvent: TJSMouseEvent): boolean;
var
  id, site: string;
begin
  site:=aEvent.targetElement.id;
  id:=Copy2SymbDel(site, '-');
  FInst:=site;
  Puter.OnOpenFileSuccess:=@ImportFile;
  Puter.OpenFileDialog;
end;

function TPuterHosting.AddSiteClick(aEvent: TJSMouseEvent): boolean;
begin
  TabBody.setContent('');
  AddNewSite;
end;

procedure TPuterHosting.UpdateSite(ASite: string);
begin
  FInstMode:=mtUpdateSite;
  Puter.OnPuterError:=@PuterError;
  TabBody.setContent('Updating website files, please wait...');
  FInst:=ASite;
  InstallSite;
  InstallFile('website', 'pyapi/website.py');
  Puter.OnDirListSuccess:=@UpdateApple2;
  Puter.OnPuterError:=@DeployApple2;
  Puter.GetDirectory(FInst+'/apple2');
end;

function TPuterHosting.SiteAction(aEvent: TJSMouseEvent): boolean;
var
  act, site: string;
begin
  site:=aEvent.targetElement.id;
  act:=Copy2SymbDel(site, '-');
  case act of
    'del': DeleteSite(aEvent);
    'edit': EditSite(aEvent);
    'exp': ExportData(aEvent);
    'imp': ImportData(aEvent);
    'upd': UpdateSite(site);
  end;
end;

function TPuterHosting.SiteSettings(aEvent: TJSMouseEvent): boolean;
var
  btn: TBulmaButton;
begin
  FSiteTitle:=TBulmaInput.Create(Self, 'Site Title', 'fsitetitle');
  btn:=TBulmaButton.Create(Self, 'Save Settings', 'SaveBtn', @SaveSettings);
  TabBody.setContent(FSiteTitle.renderHTML+btn.renderHTML);
  btn.Bind;
  FSiteTitle.Value:=FSiteTitleS;
end;

procedure TPuterHosting.SettingsLoaded(AContent: string);
var
  settings: TJSObject;
begin
  settings:=TJSJSON.parseObject(AContent);
  FSiteTitleS:=String(settings.Properties['title']);
end;

function TPuterHosting.SaveSettings(aEvent: TJSMouseEvent): boolean;
var
  settings: TSiteSettings;
begin
  FSiteTitleS:=FSiteTitle.Value;
  settings:=TSiteSettings(TJSObject.new);
  settings.title:=FSiteTitleS;
  Puter.WriteFile(FInst+'/settings.json', TJSJSON.stringify(settings));
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

